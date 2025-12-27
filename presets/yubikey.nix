# For nodes that are expected to have a YubiKey attached & should do operations with them.
{
  pkgs,
  lib,
  ...
}: {
  # Maybe consider implementing agent forwarding?
  # https://wiki.gnupg.org/AgentForwarding
  environment.systemPackages = builtins.attrValues {
    inherit
      (pkgs)
      gnupg
      yubikey-manager
      ;
  };
  programs.yubikey-touch-detector.enable = true;

  hardware.gpgSmartcards.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  services.pcscd.enable = true;
  # hack, see https://wiki.archlinux.org/title/GnuPG#Smartcards
  # pcscd is only needed for using yubikey-manager, so pcscd can be enabled when needed
  systemd.units."pcscd.service".enable = lib.mkOverride 75 false;

  # conflicts with gpg ssh agent
  services.gnome.gcr-ssh-agent.enable = false;
}
