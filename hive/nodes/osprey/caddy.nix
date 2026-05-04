{pkgs, ...}: {
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = ["github.com/mholt/caddy-l4@v0.1.0"];
      hash = "sha256-BCCz41xaWVsfN293VDC2Jo+naEZxurnhXkTHGxZS1g0=";
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
