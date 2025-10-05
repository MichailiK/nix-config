{
  nixpkgs,
  inputs,
  ilib,
  pkgs,
  modules,
  iliPresets,
  ...
}:
(nixpkgs.lib.nixosSystem {
  specialArgs = {
    inherit inputs ilib;
    nodes = { };
  };
  modules = [
    (
      {
        modulesPath,
        lib,
        ...
      }:
      {
        nixpkgs.hostPlatform = pkgs.system;
        imports = [
          "${modulesPath}/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
          "${modulesPath}/profiles/qemu-guest.nix"
        ];
        isoImage.squashfsCompression = "zstd -Xcompression-level 6";
        networking.useDHCP = lib.mkForce true;
        #boot.initrd.systemd.enable = true;
        boot.kernelPatches = [
          {
            name = "virtio-console";
            patch = null;
            extraConfig = "VIRTIO_CONSOLE y";
          }
        ];
      }
    )
  ]
  ++ (builtins.attrValues modules)
  ++ (builtins.attrValues {
    inherit (iliPresets.hive)
      base
      yubikey
      ;
    inherit (iliPresets)
      nix
      openssh
      ;
  });
}).config.system.build.isoImage
