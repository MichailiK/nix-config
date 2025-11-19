{ pkgs, ... }:
{
  programs = {
    steam = {
      enable = true;
      localNetworkGameTransfers.openFirewall = true;
    };
    obs-studio = {
      enable = true;
      enableVirtualCamera = true;
      plugins = builtins.attrValues {
        inherit (pkgs.obs-studio-plugins)
          obs-pipewire-audio-capture
          looking-glass-obs
          ;
      };
    };
  };
  services.udev.extraRules = ''
    SUBSYSTEM=="drm", ENV{DEVTYPE}=="drm_minor", ENV{DEVNAME}=="/dev/dri/card[0-9]", SUBSYSTEMS=="pci", ATTRS{vendor}=="0x1002", ATTRS{device}=="0x7480", TAG+="mutter-device-preferred-primary"
  '';
  environment.etc."xdg/monitors.xml".source = ./monitors.xml;
  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      gradia
      ;
  };
}
