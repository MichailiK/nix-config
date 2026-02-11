# For nodes that are expected to have a YubiKey attached & should do operations with them.
{
  config,
  pkgs,
  iliPkgs,
  ...
}: {
  environment.systemPackages = builtins.attrValues {
    inherit
      (pkgs)
      gnupg
      sequoia-sq
      sequoia-sqv
      yubikey-manager
      ;
  };
  # TODO uncomment once the issues with sequoia addressed below are resolved
  # programs.gnupg.package = iliPkgs.gpg-sequoia-chameleon;

  programs.yubikey-touch-detector.enable = true;

  services.pcscd.enable = true;

  # not neccessary as gpg-agent will be interacting with the card via PCSC
  # hardware.gpgSmartcards.enable = true;

  programs.gnupg.agent = {
    # sequoia-sq's openpgp-card implementation is gated behind a compiler feature-flag
    # and has an issue ive encountered https://gitlab.com/sequoia-pgp/sequoia-sq/-/issues/610
    enable = true;
    # https://codeberg.org/openpgp-card/state/issues/3
    enableSSHSupport = true;
  };

  # conflicts with other ssh agents
  services.gnome.gcr-ssh-agent.enable = false;

  systemd.user.tmpfiles.users.${config.mich.meta.defaultUser.name}.rules = let
    file = pkgs.writeText "${config.mich.meta.defaultUser.name}_scdaemon.conf" ''
      disable-ccid
      pcsc-shared
    '';
  in [
    "L+ %h/.gnupg/scdaemon.conf - - - - ${file}"
  ];
}
