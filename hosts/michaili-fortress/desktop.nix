{pkgs, ...}: {
  environment = {
    # Make Chromium & Electron applications use Wayland
    sessionVariables.NIXOS_OZONE_WL = "1";

    systemPackages = builtins.attrValues {
      inherit
        (pkgs)
        vlc
        vesktop
        handbrake
        ;
    };
  };
  programs = {
    obs-studio = {
      enable = true;
      enableVirtualCamera = true;
      plugins = builtins.attrValues {
        inherit
          (pkgs.obs-studio-plugins)
          obs-pipewire-audio-capture
          looking-glass-obs
          ;
      };
    };
    kdeconnect.enable = true;
    firefox = {
      enable = true;
      package = pkgs.librewolf;
    };
  };

  services = {
    desktopManager.plasma6.enable = true;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
  };
}
