{
  pkgs,
  lib,
  ...
}: {
  # https://github.com/NixOS/nixpkgs/issues/247608
  systemd.network.wait-online.enable = lib.mkForce false;
  networking.networkmanager.enable = true;
  networking.useNetworkd = true;

  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    wireplumber.enable = true;
    pulse.enable = true;
  };

  fonts = {
    fontconfig.useEmbeddedBitmaps = true;
    enableDefaultPackages = true;
  };
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
      inherit
        (pkgs)
        vlc
        vesktop
        handbrake
        vscode-fhs
        zed-editor
        ;
    };
  };
}
