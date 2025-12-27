{...}: {
  imports = [./base.nix];

  boot.plymouth = {
    enable = true;
    theme = "spinner";
  };

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
}
