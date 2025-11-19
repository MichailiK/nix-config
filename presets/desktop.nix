{ pkgs, ... }:
{
  boot.plymouth = {
    enable = true;
    theme = "spinner";
  };
  /*
    services.desktopManager.plasma6.enable = true;
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
  */
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.gnome.gcr-ssh-agent.enable = false;

  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    wireplumber.enable = true;
    pulse.enable = true;
  };

  networking.networkmanager.enable = true;
  networking.useNetworkd = true;

  fonts.enableDefaultPackages = true;
  /*
    services.printing.enable = true;
    hardware.sane = {
      enable = true;
      extraBackends = [pkgs.sane-airscan];
    };
  */

  programs.kdeconnect.enable = true;
  programs.firefox = {
    enable = true;
    package = pkgs.librewolf;
  };

  programs.direnv.enable = true;

  environment = {
    # Make Chromium & Electron applications use Wayland
    sessionVariables.NIXOS_OZONE_WL = "1";

    systemPackages = builtins.attrValues {
      inherit (pkgs)
        vlc
        vesktop
        handbrake
        vscode-fhs
        zed-editor
        ;
    };
  };
}
