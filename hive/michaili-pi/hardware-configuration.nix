{
  inputs,
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "usbhid" "usb_storage" "sr_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
    fsType = "ext4";
  };
  fileSystems."/storage/ssd1" = {
    device = "/dev/disk/by-uuid/4c6476ef-e404-4c2d-a3d9-d74b3cc2a20f";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "noatime"
      "nofail"
    ];
  };
  fileSystems."/storage/hdd1" = {
    device = "/dev/disk/by-uuid/872d147c-c0fe-44f4-b06d-81a3d8cb4273";
    fsType = "xfs";
    options = [
      "logdev=/dev/disk/by-partuuid/19f8d5f7-9efc-45e4-ab94-cc623b97245b"
      "nofail"
    ];
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/d93c6145-a088-4fbe-8d26-0f86ecb0645c";
      options = ["nofail"];
    }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
