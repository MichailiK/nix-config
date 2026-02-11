{pkgs, ...}: {
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = ["github.com/mholt/caddy-l4@v0.0.0-20260104223739-97fa8c1b6618"];
      hash = "sha256-9tFRk+ULLh99eSPiNtiusH9yqcIJkVuJOEaeS43s8Tc=";
    };
    virtualHosts = {
      "michai.li" = {
        extraConfig = ''
          root * /srv/http/michai.li
          encode
          file_server
        '';
      };
      "www.michai.li" = {
        extraConfig = ''
          redir https://michai.li{uri}
        '';
      };
    };
  };
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [443];
}
