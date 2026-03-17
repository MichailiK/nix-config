{
  lib,
  options,
  ...
}: {
  imports = [./base.nix];

  boot.plymouth = {
    enable = true;
    theme = "spinner";
  };

  services.desktopManager.plasma6.enable = true;
  # use plasma-login-manager on nixpkgs 26.05 and later. older nixpkgs only have sddm.
  services.displayManager =
    if (builtins.hasAttr "plasma-login-manager" options.services.displayManager)
    then {
      plasma-login-manager.enable = true;
    }
    else {
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };
}
