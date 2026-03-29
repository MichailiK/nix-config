{...}: {
  # TODO add LibreChat container here

  services.caddy.virtualHosts."librechat.michai.li".extraConfig = ''
    reverse_proxy :3080
  '';
}
