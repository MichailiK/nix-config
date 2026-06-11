{
  pkgs,
  lib,
  ...
}: let
  patchedGamja = pkgs.runCommandLocal "${pkgs.gamja.name}_patched" {} ''
    cp -rT ${pkgs.gamja} $out
    chmod -R +w $out
    cd $out

    jsFile=$(ls source.*.js  | grep -v '\.map$' | head -n1)
    cssFile=$(ls source.*.css | grep -v '\.map$' | head -n1)

    jsHash="sha256-$(${lib.getExe pkgs.openssl} dgst -sha256 -binary "$jsFile"  | ${lib.getExe pkgs.openssl} base64 -A)"
    cssHash="sha256-$(${lib.getExe pkgs.openssl} dgst -sha256 -binary "$cssFile" | ${lib.getExe pkgs.openssl} base64 -A)"

    # Remove the CSP <meta> tag from the original HTML
    ${lib.getExe pkgs.gnused} -i \
      's|<meta http-equiv="Content-Security-Policy"[^>]*>||' \
      index.html

    # Add SRI hash of the stylesheet in the original HTML
    ${lib.getExe pkgs.gnused} -i \
      "s|<link rel=\"stylesheet\" href=\"$cssFile\"|<link rel=\"stylesheet\" href=\"$cssFile\" integrity=\"$cssHash\" crossorigin=\"anonymous\"|" \
      index.html

    # Add SRI hash of the script to the original HTML
    ${lib.getExe pkgs.gnused} -i \
      "s|<script type=\"module\" src=\"$jsFile\"|<script type=\"module\" src=\"$jsFile\" integrity=\"$jsHash\" crossorigin=\"anonymous\"|" \
      index.html

    echo -n "$jsHash"  > $out/.js-sri
    echo -n "$cssFile" > $out/.css-filename

    # A bit silly to configure gamja here but this is for my personal use anyway
    echo -n '{"server":{"auth":"mandatory"}}' > $out/config.json
  '';
in {
  # Most of this is "inspired" from
  # https://codeberg.org/emersion/soju/src/commit/84ca9cf64007e1f432d986bde59505e33545f30c/contrib/caddy.md
  services.soju = {
    enable = true;
    listen = [
      "irc://localhost:6667"
      "http://localhost:3030"
      "ident://"
    ];
    acceptProxyIP = ["localhost"];
    hostName = "irc.michai.li";
  };
  # To allow soju to listen to TCP port tcp/113 (ident)
  systemd.services.soju.serviceConfig.AmbientCapabilities = ["CAP_NET_BIND_SERVICE"];

  networking.firewall.allowedTCPPorts = [113 6697];

  services.caddy = {
    globalConfig = ''
      layer4 {
        irc.michai.li:6697 {
          route {
            tls {
              connection_policy {
                alpn irc
              }
            }
            proxy {
              proxy_protocol v2
              upstream localhost:6667
            }
          }
        }
      }
    '';

    virtualHosts."irc.michai.li".extraConfig = ''
      header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"

      @soju {
        path /socket
        path /uploads
        path /uploads/*
      }
      reverse_proxy @soju localhost:3030

      redir /index.html / 301

      header X-Content-Type-Options "nosniff"
      header Cross-Origin-Resource-Policy "same-site"

      @root path /
      header @root Content-Security-Policy "${lib.join "; " [
        "default-src 'none'"
        "base-uri 'none'"
        "form-action 'none'"
        "frame-ancestors 'none'"
        "script-src '${builtins.readFile "${patchedGamja}/.js-sri"}'"
        "style-src https://irc.michai.li/${builtins.readFile "${patchedGamja}/.css-filename"}"
        "manifest-src https://irc.michai.li/manifest.webmanifest"
        "connect-src 'self'"
        "upgrade-insecure-requests"
      ]}"
      header @root Referrer-Policy "no-referrer"

      # Serve gamja files
      root * ${patchedGamja}
      file_server {
        hide .js-sri .css-filename
      }
    '';
  };
}
