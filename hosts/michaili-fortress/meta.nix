{
  imports = [
    # TODO improve
    ../../templates/base.nix
    ../../templates/flakes.nix
    ../../templates/desktop.nix
    ../../templates/yubikey.nix
  ];

  mich.meta = {
    ssh = {
      knowNodesPublicKeys = true;
      trustedWithAgentForwarding = true;
    };
  };

  networking.hostName = "michaili-fortress";
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";

  system.stateVersion = "23.11";
}
