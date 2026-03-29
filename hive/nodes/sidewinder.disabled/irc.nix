{pkgs, ...}: {
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
      @soju {
        path /socket
        path /uploads
        path /uploads/*
      }
      reverse_proxy @soju localhost:3030

      # Serve gamja files
      root * ${pkgs.gamja}
      file_server
    '';
  };
}
