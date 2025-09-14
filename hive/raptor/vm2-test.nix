{pkgs, ...}: {
  ### Network Devices ###
  systemd.network = {
    netdevs = {
      "br-vm1".netdevConfig = {
        Kind = "bridge";
        Name = "br-vm1";
      };
      # Services like radvd & Kea need a running interface to attach sockets to.
      # The dummy device ensures that even if the associated VM is shut down,
      # the bridge stays up.
      "dummy-br-vm1".netdevConfig = {
        Kind = "dummy";
        Name = "dummy-br-vm1";
      };
    };
    networks = {
      "br-vm1" = {
        matchConfig.Name = "br-vm1";

        linkConfig = {RequiredForOnline = false;};
        networkConfig = {
          LinkLocalAddressing = false;
          ConfigureWithoutCarrier = true;
          IPv4Forwarding = true;
          IPv6Forwarding = true;
        };
        addresses = [{Address = "169.254.1.1/32";} {Address = "fe80::1/64";}];
        routes = [
          {
            Destination = "188.40.162.194/32";
            Scope = "link";
            PreferredSource = "188.40.162.193";
          }
          {Destination = "2a01:04f8:0120:11e6:f001::1/80";}
        ];
      };
      "dummy-br-vm1" = {
        matchConfig.Name = "dummy-br-vm1";
        networkConfig.Bridge = "br-vm1";
      };
    };
  };

  ### IPv6 Router Advertisements ###
  services.radvd = {
    enable = true;
    config = ''
      interface br-vm1
      {
          AdvSendAdvert on;
          AdvManagedFlag on; # Tell clients to use DHCPv6 to obtain address
          AdvOtherConfigFlag on; # Tell clients to get info like DNS via DHCPv6

          # Tell clients to not auto-configure an address from the RA.
          prefix 2a01:4f8:120:11e6:f001::/80
          {
            AdvOnLink on;
            AdvAutonomous off;
          };
      };
    '';
  };

  ### DHCP for IPv4 and IPv6 ###
  services.kea = let
    keaHooksPath = "${pkgs.kea}/lib/kea/hooks";
    flexIdHook = {
      library = "${keaHooksPath}/libdhcp_flex_id.so";
      parameters = {
        identifier-expression = "pkt.iface";
        replace-client-id = true;
        ignore-iaid = true;
      };
    };
  in {
    dhcp4 = {
      enable = true;
      settings = {
        hooks-libraries = [
          {library = "${keaHooksPath}/libdhcp_lease_cmds.so";}
          flexIdHook
        ];
        control-sockets = [
          {
            socket-type = "unix";
            socket-name = "/run/kea/dhcp4-server.sock";
          }
        ];

        interfaces-config = {
          interfaces = ["br-vm1"];
          dhcp-socket-type = "raw";
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

        host-reservation-identifiers = ["flex-id"];

        subnet4 = [
          {
            id = 1;
            subnet = "188.40.162.192/29";
            interface = "br-vm1";
            reservations = [
              {
                flex-id = "'br-vm1'";
                ip-address = "188.40.162.194";
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
          {library = "${keaHooksPath}/libdhcp_lease_cmds.so";}
          flexIdHook
        ];
        control-sockets = [
          {
            socket-type = "unix";
            socket-name = "/run/kea/dhcp6-server.sock";
          }
        ];

        interfaces-config = {
          interfaces = ["br-vm1"];
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

        host-reservation-identifiers = ["flex-id"];

        subnet6 = [
          {
            id = 1;
            subnet = "2a01:4f8:120:11e6::/64";
            interface = "br-vm1";
            reservations = [
              {
                flex-id = "'br-vm1'";
                prefixes = ["2a01:4f8:120:11e6:f001::/80"];
                ip-addresses = ["2a01:4f8:120:11e6:f001::1"];
              }
            ];
          }
        ];
      };
    };
  };
}
