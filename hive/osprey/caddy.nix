{pkgs, ...}: {
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = ["github.com/mholt/caddy-l4@v0.1.0"];
      hash = "sha256-BCCz41xaWVsfN293VDC2Jo+naEZxurnhXkTHGxZS1g0=";
    };
    virtualHosts = {
      "s3.michai.li" = {
        extraConfig = ''
          reverse_proxy unix//run/garage/s3.sock {
            transport http {
              dial_timeout 2s
            }
          }
          handle_errors {
            @502-503 expression `{err.status_code} in [502, 503]`
            handle @502-503 {
              header Content-Type "application/xml"
              respond `<?xml version="1.0" encoding="UTF-8"?><Error><Code>ServiceUnavailable</Code><Message>The service is temporarily unavailable. Please try again later.</Message></Error>` 503
            }
          }
        '';
      };
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
