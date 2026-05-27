{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "virtio_pci"
    "virtio_scsi"
    "sr_mod"
    "virtio_blk"
  ];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/e61acf30-2d25-48cb-af43-550d8354cae8";
    fsType = "btrfs";
    options = [
      "subvol=root"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/e61acf30-2d25-48cb-af43-550d8354cae8";
    fsType = "btrfs";
    options = [
      "subvol=nix"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/e61acf30-2d25-48cb-af43-550d8354cae8";
    fsType = "btrfs";
    options = [
      "subvol=home"
      "compress=zstd"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/15FB-CE71";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  fileSystems."/storage/hdd1" = {
    device = "/dev/disk/by-uuid/363f6d75-ac39-4c1c-b1e2-1b127d77cc1b";
    fsType = "xfs";
    options = [
      "logdev=/dev/disk/by-partuuid/0b7998e1-b698-4e56-a127-d4d4c3a5c098" # 2 GiB partition on NVMe SSD
      "noatime"
    ];
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/93a46c9e-2b0d-4e60-a4bb-5e470b573cba";}
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
