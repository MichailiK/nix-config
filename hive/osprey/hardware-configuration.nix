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
    device = "/dev/disk/by-uuid/f74da48e-a96d-4698-b48e-3561b7b3f20b";
    fsType = "btrfs";
    options = [
      "subvol=root"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/f74da48e-a96d-4698-b48e-3561b7b3f20b";
    fsType = "btrfs";
    options = [
      "subvol=nix"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/f74da48e-a96d-4698-b48e-3561b7b3f20b";
    fsType = "btrfs";
    options = [
      "subvol=home"
      "compress=zstd"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/3DC5-B5BE";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  fileSystems."/var/lib/garage/data" = {
    device = "/dev/disk/by-uuid/ce68b1ad-62dc-443e-bfa7-811cb7f98dd2";
    fsType = "xfs";
    options = [
      "logdev=/dev/disk/by-partuuid/21a6306b-6c19-4378-a1e2-37f4546ba952" # 1 GiB partition on NVMe SSD
      "noatime"
    ];
  };

  fileSystems."/var/lib/garage/meta" = {
    device = "/dev/disk/by-uuid/f74da48e-a96d-4698-b48e-3561b7b3f20b";
    fsType = "btrfs";

    options = [
      "subvol=garage-metadata"
      "compress=zstd"
      "noatime"
    ];
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/57178162-4038-4369-b7a9-7a58356099de";}
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
