{
  pkgs,
  lib,
  ...
}:
let
  # This exists because Nix's string interpolation cannot coerce integers to strings
  # and I can't be bothered to read "br-vm${builtins.toString vm.id}" everywhere.
  mkId = number: {
    value = number;
    __toString = self: builtins.toString self.value;
  };

  # VM bridges to create with explicit IPv4 address.
  # IPv6 subnet will automatically be assigned based on id.
  VM_BRIDGES = [
    {
      id = mkId 1;
      ipv4 = "188.40.162.194";
    }
    {
      id = mkId 2;
      ipv4 = "188.40.162.195";
    }
    {
      id = mkId 3;
      ipv4 = "188.40.162.196";
    }
    {
      id = mkId 4;
      ipv4 = "188.40.162.197";
    }
    {
      id = mkId 5;
      ipv4 = "188.40.162.198";
    }
  ];
  # accepts integer & returns a hex string padded with 2 characters, e.g. 01, 0a, 1c
  toPaddedHex =
    integer:
    let
      hex = lib.toHexString integer;
    in
    if (builtins.stringLength hex == 1) then "0${hex}" else hex;

  # returns INCOMPLETE presentation of IPv6 address based on ID.
  # 1 => 2a01:04f8:0120:11e6:f001
  # 2 => 2a01:04f8:0120:11e6:f002
  # ...
  # you may want to add
  # - ::1 (for referring to an IP address)
  # - or ::/80 (for the subnet)
  ipv6FromVmId = id: "2a01:04f8:0120:11e6:f0" + (toPaddedHex id.value);
in
{
  networking.firewall = {
    # TODO the eno1 interface name may not be stable. Ideally the interface's MAC address would be used here or something else.
    extraCommands = ''
      iptables -A FORWARD -s 188.40.162.192/29 -o eno1 -j ACCEPT
      iptables -A FORWARD -d 188.40.162.192/29 -i eno1 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT

      ${lib.pipe VM_BRIDGES [
        (builtins.map (vm: ''
          iptables -A INPUT -i br-vm${vm.id} -p udp -m udp --dport 67 -j ACCEPT
          ip6tables -A INPUT -i br-vm${vm.id} -p udp -m udp --dport 547 -j ACCEPT
        ''))
        (lib.concatStringsSep "\n")
      ]}
    '';
  };

  ### Network Devices ###
  systemd.network =
    let
      netDevices = (
        builtins.map (vm: {
          # Services like radvd & Kea need a running interface to attach sockets to.
          # The dummy device ensures that even if the associated VM is shut down,
          # the bridge stays up.
          "dummy-br-vm${vm.id}" = {
            NETDEV.netdevConfig.Kind = "dummy";
            NETWORK.networkConfig.Bridge = "br-vm${vm.id}";
          };
          "br-vm${vm.id}" = {
            NETDEV.netdevConfig.Kind = "bridge";
            NETWORK = {
              linkConfig = {
                RequiredForOnline = false;
              };
              networkConfig = {
                LinkLocalAddressing = false;
                ConfigureWithoutCarrier = true;
                IPv4Forwarding = true;
                IPv6Forwarding = true;
              };
              addresses = [
                { Address = "169.254.${vm.id}.1/32"; }
                { Address = "fe80::1/64"; }
              ];
              routes =
                # NAT could be implemented if the VM has no dedicated IP but bleh
                (lib.optionals (vm.ipv4 != null) [
                  {
                    Destination = "${vm.ipv4}/32";
                    Scope = "link";
                    PreferredSource = "188.40.162.193";
                  }
                ])
                ++ [ { Destination = (ipv6FromVmId vm.id) + "::1/80"; } ];
            };
          };
        }) VM_BRIDGES
      );

      mergedNetDevices = lib.mergeAttrsList netDevices;
    in
    {
      netdevs = builtins.mapAttrs (
        name: value: lib.attrsets.recursiveUpdate value.NETDEV { netdevConfig.Name = name; }
      ) mergedNetDevices;

      networks = builtins.mapAttrs (
        name: value: lib.attrsets.recursiveUpdate value.NETWORK { matchConfig.Name = name; }
      ) mergedNetDevices;
    };

  ### IPv6 Router Advertisements ###
  services.radvd = {
    enable = true;
    config = lib.pipe VM_BRIDGES [
      (builtins.map (vm: ''
        interface br-vm${vm.id}
        {
            AdvSendAdvert on;
            AdvManagedFlag on; # Tell clients to use DHCPv6 to obtain address
            AdvOtherConfigFlag on; # Tell clients to get info like DNS via DHCPv6

            # Tell clients to not auto-configure an address from the RA.
            prefix ${ipv6FromVmId vm.id}::/80
            {
              AdvOnLink on;
              AdvAutonomous off;
            };
        };
      ''))
      (lib.concatStringsSep "\n")
    ];
  };

  ### DHCP for IPv4 and IPv6 ###
  services.kea =
    let
      keaHooksPath = "${pkgs.kea}/lib/kea/hooks";
      flexIdHook = {
        library = "${keaHooksPath}/libdhcp_flex_id.so";
        parameters = {
          identifier-expression = "pkt.iface";
          replace-client-id = true;
          ignore-iaid = true;
        };
      };
    in
    {
      dhcp4 = {
        enable = true;
        # MAJOR HACK: Most DHCP server implementations cant cope with the routed/L3
        # setup used here, so relays would be used for this. dnsmasq is the only
        # maintained DHCP relay, and it is hard-coded to bind to 0.0.0.0:67
        # for some reason, so we are changing Kea's DHCPv4 port to 167 and make
        # DHCP relays send requests to that port.
        extraArgs = [ "-p167" ];
        settings = {
          hooks-libraries = [
            { library = "${keaHooksPath}/libdhcp_lease_cmds.so"; }
            #flexIdHook
          ];
          control-sockets = [
            {
              socket-type = "unix";
              socket-name = "/run/kea/dhcp4-server.sock";
            }
          ];

          interfaces-config = {
            #interfaces = lib.pipe VM_BRIDGES [
            #  (builtins.filter (vm: vm.ipv4 != null))
            #  (builtins.map (vm: "br-vm${vm.id}"))
            #];
            interfaces = [ "lo" ];
            dhcp-socket-type = "udp";
          };

          lease-database = {
            type = "memfile";
            persist = true;
          };
          min-valid-lifetime = 4294967295;
          valid-lifetime = 4294967295;

          option-data = [
            {
              name = "routers";
              data = "188.40.162.193";
            }
            {
              name = "domain-name-servers";
              data = "1.1.1.1, 1.0.0.1";
            }
          ];

          host-reservation-identifiers = [
            # "flex-id"
            "hw-address"
          ];
          reservations-global = true;
          reservations-in-subnet = false;

          /*
            subnet4 =
            builtins.map (vm: {
              id = vm.id.value;
              subnet = "188.40.162.192/29";
              interface = "br-vm${vm.id}";
              reservations = [
                {
                  flex-id = "'br-vm${vm.id}'";
                  ip-address = vm.ipv4;
                }
              ];
            })
            VM_BRIDGES;
          */
          reservations = builtins.map (vm: {
            #flex-id = "'br-vm${vm.id}'";
            hw-address = "52:54:00:00:00:${toPaddedHex vm.id.value}";
            ip-address = vm.ipv4;
          }) VM_BRIDGES;

          shared-networks = [
            {
              name = "vm-networks";
              relay = {
                ip-addresses = builtins.map (vm: "169.254.${vm.id}.1") VM_BRIDGES;
              };
              subnet4 = [
                {
                  id = 1;
                  subnet = "188.40.162.192/29";
                  reservations-global = true;
                  reservations-in-subnet = false;
                  #interface = "br-vm1"; # TEMP
                }
              ];
            }
          ];
        };
      };

      dhcp6 = {
        enable = true;
        settings = {
          hooks-libraries = [
            { library = "${keaHooksPath}/libdhcp_lease_cmds.so"; }
            flexIdHook
          ];
          control-sockets = [
            {
              socket-type = "unix";
              socket-name = "/run/kea/dhcp6-server.sock";
            }
          ];

          interfaces-config = {
            interfaces = builtins.map (vm: "br-vm${vm.id}") VM_BRIDGES;
          };

          lease-database = {
            type = "memfile";
            persist = true;
          };
          min-preferred-lifetime = 4294967295;
          preferred-lifetime = 4294967295;
          min-valid-lifetime = 4294967295;
          valid-lifetime = 4294967295;

          option-data = [
            {
              name = "dns-servers";
              data = "2606:4700:4700::1111, 2606:4700:4700::1001";
            }
          ];

          host-reservation-identifiers = [ "flex-id" ];

          subnet6 = builtins.map (vm: {
            id = vm.id.value;
            #subnet = "2a01:4f8:120:11e6::/64";
            subnet = "${ipv6FromVmId vm.id}::/80";
            interface = "br-vm${vm.id}";
            reservations = [
              {
                flex-id = "'br-vm${vm.id}'";
                prefixes = [ "${ipv6FromVmId vm.id}::/80" ];
                ip-addresses = [ "${ipv6FromVmId vm.id}::1" ];
              }
            ];
          }) VM_BRIDGES;
        };
      };
    };

  ### DNSMASQ as a DHCP relay ###
  services.dnsmasq = {
    enable = true;
    settings = {
      port = 0; # disable DNS server
      interface = builtins.map (vm: "br-vm${vm.id}") VM_BRIDGES;
      except-interface = "lo";
      bind-interfaces = true;
      dhcp-relay = builtins.map (vm: "169.254.${vm.id}.1,127.0.0.1#167") VM_BRIDGES;
    };
  };
}
