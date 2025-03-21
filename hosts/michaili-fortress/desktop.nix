{pkgs, ...}: {
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.systemPackages = [
    pkgs.vlc
    pkgs.vesktop
    pkgs.handbrake
  ];
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-pipewire-audio-capture
      looking-glass-obs
    ];
  };
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
