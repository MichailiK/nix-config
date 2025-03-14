{pkgs, ...}: {
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.systemPackages = [
    pkgs.vlc
    (pkgs.wrapOBS {
      plugins = with pkgs.obs-studio-plugins; [
        obs-pipewire-audio-capture
        looking-glass-obs
      ];
    })
    pkgs.vesktop
    pkgs.handbrake
  ];
  programs.kdeconnect = {enable = true;};
  services = {
    desktopManager.plasma6.enable = true;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
  };
  programs = {
    firefox = {
      enable = true;
      package = pkgs.librewolf;
    };
  };
}
