{pkgs, ...}: {
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.systemPackages = [
    pkgs.vlc
    pkgs.obs-studio
    pkgs.vesktop
    pkgs.handbrake
  ];
  hardware.pulseaudio.enable = false;
  services = {
    xserver.desktopManager.gnome.enable = true;
    #desktopManager.plasma6.enable = true;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
  };
  programs = {
    firefox.enable = true;
  };
}
