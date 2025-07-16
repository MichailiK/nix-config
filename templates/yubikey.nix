# For nodes that are expected to have a YubiKey attached & should do operations with them.
{ pkgs, ... }:
{
  # Maybe consider implementing agent forwarding?
  # https://wiki.gnupg.org/AgentForwarding
  environment.systemPackages = builtins.attrValues {
    inherit
      (pkgs)
      gnupg
      yubikey-manager;
  };
  programs.yubikey-touch-detector.enable = true;

  hardware.gpgSmartcards.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  services.pcscd.enable = true;
}
