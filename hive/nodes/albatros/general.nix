{config, ...}: {
  boot.loader.grub.device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_114787231";

  security.sudo = {
    wheelNeedsPassword = false;
    execWheelOnly = true;
  };

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };
  services.getty.autologinUser = config.mich.meta.defaultUser.name;
  networking = {
    useDHCP = false;
    useNetworkd = true;
    firewall.logRefusedConnections = false;
    firewall.extraCommands = ''
      iptables -A INPUT -p udp --dport 33434:33534 -j REJECT --reject-with icmp-port-unreachable
      ip6tables -A INPUT -p udp --dport 33434:33534 -j REJECT --reject-with icmp6-port-unreachable
    '';
  };
  systemd.network = {
    enable = true;
    networks = {
      internet = {
        matchConfig = {
          Name = "enp1s0";
        };
        dns = [
          "2606:4700:4700::1111" # Cloudflare IPv6 primary
          "2606:4700:4700::1001" # Cloudflare IPv6 secondary
          "1.1.1.1" # Cloudflare IPv4 primary
          "1.0.0.1" # Cloudflare IPv4 secondary
        ];
        addresses = [
          {Address = "2a01:4f8:c014:6465::1/64";} # albatros.michai.li
        ];
        routes = [{Gateway = "fe80::1";}];
        networkConfig = {
          DHCP = true;
          IPv4Forwarding = true;
          IPv6Forwarding = true;
          #IPv4ProxyARP = true;
          #IPv6ProxyNDP = true;
        };
        cakeConfig = {
          Bandwidth = "1G";
          FlowIsolationMode = "dual-src-host"; # fairness is applied over source IPs first, then flows within them.
        };
      };
    };
  };
}
