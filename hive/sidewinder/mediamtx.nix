{
  networking.firewall = {
    allowedUDPPorts = [8189];
  };

  services.caddy.virtualHosts."live.michai.li".extraConfig = ''
    reverse_proxy localhost:8889
  '';

  services.mediamtx = {
    enable = true;
    settings = {
      authInternalUsers = [
        {
          user = "any";
          permissions = [
            {
              action = "read";
            }
          ];
        }
        {
          user = "michaili";
          pass = "sha256:JgLrrdTSDtwNJRoVkbMCzm9sXe5+dKpIto0N+urQpXY="; # TODO get argon2 hash working
          permissions = [
            {
              action = "publish";
              path = "michaili";
            }
          ];
        }
      ];

      paths = {
        michaili.source = "publisher";
      };
      pathDefaults.useAbsoluteTimestamp = false;
    };
  };
}
