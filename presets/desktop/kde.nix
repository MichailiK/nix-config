{...}: {
  imports = [./base.nix];

  boot.plymouth = {
    enable = true;
    theme = "spinner";
  };

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
}
