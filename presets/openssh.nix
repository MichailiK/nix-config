{
  config,
  lib,
  ...
}: {
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  # Allows using private SSH keys for authentication via PAM
  security.pam = lib.mkIf config.services.openssh.enable {
    services.sudo.rssh = true;
    rssh = {
      enable = true;
      settings = {
        cue = true;
      };
    };
  };
}
