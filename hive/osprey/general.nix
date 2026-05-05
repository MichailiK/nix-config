{config, ...}: {
  boot.loader.systemd-boot.enable = true;

  boot.kernelParams = ["zswap.enabled=1" "zswap.shrinker_enabled=1"];
  boot.initrd.systemd.enable = true;

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
    # view in `networkctl status <interface>`
    config.networkConfig.SpeedMeter = true;

    enable = true;
    networks = {
      internet = {
        matchConfig = {
          MACAddress = "16:fe:9b:b8:74:c0";
        };
        dns = [
          "2606:4700:4700::1111" # Cloudflare IPv6 primary
          "2606:4700:4700::1001" # Cloudflare IPv6 secondary
          "1.1.1.1" # Cloudflare IPv4 primary
          "1.0.0.1" # Cloudflare IPv4 secondary
        ];
        addresses = [
          {Address = "193.24.209.106/24";} # osprey.michai.li
          {Address = "2a00:1911:0001:f6cb:812e:1366:be06:a9f2/48";} # layer7 provided IPv6 address
          {Address = "2a00:1913:3311::1/48";} # osprey.michai.li
        ];
        routes = [
          {Gateway = "193.24.209.1";}
          {Destination = "2a00:1913::1/128";} # Off-link gateway for /48 subnet
          {
            # Preferred default route
            Gateway = "2a00:1913::1";
            PreferredSource = "2a00:1913:3311::1";
            Metric = 100;
          }
          {
            # Layer7 provided IPv6 default route
            Gateway = "2a00:1911:1::1";
            PreferredSource = "2a00:1911:0001:f6cb:812e:1366:be06:a9f2";
            Metric = 200;
          }
        ];
        networkConfig = {
          #DHCP = true;
          #IPv4Forwarding = true;
          #IPv6Forwarding = true;
          #IPv6AcceptRA = false;
        };
        cakeConfig = {
          Bandwidth = "1G";
          FlowIsolationMode = "dual-src-host"; # fairness is applied over source IPs first, then flows within them.
        };
      };
    };
  };
}
