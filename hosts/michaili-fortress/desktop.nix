{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.vlc
    pkgs.obs-studio
    pkgs.vesktop
    pkgs.handbrake
  ];
  services = {
    desktopManager.plasma6.enable = true;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
  };
  programs = {
    firefox.enable = true;
  };
}
