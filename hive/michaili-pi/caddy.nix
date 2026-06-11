{
  pkgs,
  lib,
  ...
}: {
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = ["github.com/mholt/caddy-l4@v0.1.0"];
      hash = "sha256-V0L5QdeZfbRkLriGMdqFK/p3iHyGRiAAYYqcSMZ5E04=";
    };
    virtualHosts = {
      /*
      "s3.michai.li" = {
        extraConfig = ''
          header Strict-Transport-Security max-age=63072000; includeSubDomains; preload

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
      */
      "michai.li" = {
        extraConfig = ''
          header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
          header X-Robots-Tag "noindex"
          header Content-Security-Policy "${lib.join "; " [
            "default-src 'none'"
            "base-uri 'none'"
            "form-action 'none'"
            "frame-ancestors 'none'"
            "style-src 'sha256-2LxHFThVaRB5fFzwSw3EIkCJ10XBZz8Kl60kKm64HDQ='"
            "media-src 'self'"
            "sandbox"
            "upgrade-insecure-requests"
          ]}"
          header X-Content-Type-Options "nosniff"
          header X-Frame-Options "DENY"
          header No-Vary-Search "params"

          root * /srv/http/michai.li
          encode
          file_server
        '';
      };
      "www.michai.li" = {
        extraConfig = ''
          header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"

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
