{
  lib,
  pkgs,
  ...
}: {
  networking.firewall.allowedUDPPorts = [51820];
  networking.wireguard.interfaces.via-relay = {
    #ips = ["10.0.0.1/30"];
    listenPort = 51820;
    privateKeyFile = "/etc/via-relay/private";
    #postSetup = "${lib.getExe' pkgs.procps "sysctl"} -w net.ipv4.conf.via-relay.forwarding=1";
    peers = [
      {
        publicKey = "Mn2/W61T9S+7FKUNXZtR1w0k7+BK2GAJMmQlqrvDeT4=";
        presharedKeyFile = "/etc/via-relay/peer_psk";
        allowedIPs = [
          #"10.0.0.2/32"
          "5.75.217.111/32" # via-relay.michai.li
          "2a01:4f8:c014:6465::7672/128" # via-relay.michai.li
        ];
      }
    ];
  };
  systemd.network = {
    # required as the kernel will do no IPv6 forwarding unless the
    # global IPv6 forwarding sysctl is enabled.
    # NOTE: one could set the net.ipv6.conf.<iface>.force_forwarding
    # sysctl but systemd-network doesnt let you conveniently set that sysctl
    config.networkConfig.IPv6Forwarding = true;

    # fingers crossed that the naming scheme wont be changed in wireguard-networkd
    # https://github.com/NixOS/nixpkgs/blob/1073dad219cb244572b74da2b20c7fe39cb3fa9e/nixos/modules/services/networking/wireguard-networkd.nix#L79
    networks."40-via-relay" = {
      networkConfig = {
        IPv4Forwarding = true;
        IPv6Forwarding = true;
        #IPv4ProxyARP = true;
        #IPv6ProxyNDP = true;
      };
    };
  };
}
