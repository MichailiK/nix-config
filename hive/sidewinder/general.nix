{ config, ... }:
{

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  security.sudo = {
    wheelNeedsPassword = false;
    execWheelOnly = true;
  };

  virtualisation.docker = {
    enable = true;
  };

  services.caddy = {
    enable = true;
    virtualHosts = {
      "michai.li" = {
        serverAliases = [ "www.michai.li" ];
        extraConfig = ''
          root * /srv/http/michai.li
          encode
          file_server
        '';
      };
    };
  };

  services.openssh = {
    enable = true;
    openFirewall = false; # Firewall rules for SSH are set manually below
    settings.PasswordAuthentication = false;
  };
  services.getty.autologinUser = config.mich.meta.defaultUser.name;

  networking.firewall.logRefusedConnections = false;
  networking.firewall.extraCommands = ''
    iptables -A INPUT -p udp --dport 33434:33534 -j REJECT --reject-with icmp-port-unreachable
    ip6tables -A INPUT -p udp --dport 33434:33534 -j REJECT --reject-with icmp6-port-unreachable

    # Only allow incoming SSH connections from the internal network
    iptables -A INPUT -p tcp --dport 22 -s 188.40.162.192/29 -j ACCEPT
    iptables -A INPUT -p tcp --dport 22 -s 78.46.83.238 -j ACCEPT
    ip6tables -A INPUT -p tcp --dport 22 -s 2a01:4f8:120:11e6::/64 -j ACCEPT
  '';
}
