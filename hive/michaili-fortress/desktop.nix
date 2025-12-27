{
  pkgs,
  lib,
  config,
  ...
}: {
  programs = {
    steam = {
      enable = true;
      localNetworkGameTransfers.openFirewall = true;
    };
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
  };
  services.udev.extraRules = lib.mkIf config.services.desktopManager.gnome.enable ''
    SUBSYSTEM=="drm", ENV{DEVTYPE}=="drm_minor", ENV{DEVNAME}=="/dev/dri/card[0-9]", SUBSYSTEMS=="pci", ATTRS{vendor}=="0x1002", ATTRS{device}=="0x7480", TAG+="mutter-device-preferred-primary"
  '';
}
