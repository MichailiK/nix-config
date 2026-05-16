{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  environment.systemPackages = builtins.attrValues {
    inherit
      (pkgs)
      libraspberrypi
      raspberrypi-eeprom
      ;
  };

  # use mainline kernel instead of rpi one
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = ["usbcore.autosuspend=-1"];

  security.sudo.wheelNeedsPassword = false;

  systemd.network = {
    # view in `networkctl status <interface>`
    config.networkConfig.SpeedMeter = true;
  };
}
