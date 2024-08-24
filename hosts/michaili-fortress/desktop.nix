{pkgs, ...}: {
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.systemPackages = [
    pkgs.vlc
    pkgs.obs-studio
    pkgs.vesktop
    pkgs.handbrake
  ];
  programs.kdeconnect = { enable = true; package = pkgs.gnomeExtensions.gsconnect; }
  hardware.pulseaudio.enable = false;
  services = {
    xserver = {
      enable = true;
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = true;
    };
    #desktopManager.plasma6.enable = true;
    #displayManager.sddm = {
    #  enable = true;
    #  wayland.enable = true;
    #};
  };
  programs = {
    firefox.enable = true;
    dconf.profiles.user.databases = [
      { settings."org/gnome/desktop/input-sources".sources = "[('xkb' 'eu')]"; }
    ];
  };
}
