{...}: {
  # TODO add LibreChat container here

  services.caddy.virtualHosts."librechat.michai.li".extraConfig = ''
    header Strict-Transport-Security max-age=63072000; includeSubDomains; preload
    reverse_proxy :3080
  '';
}
