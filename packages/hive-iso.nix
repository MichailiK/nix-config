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
  specialArgs = { inherit inputs ilib; nodes = {}; };
  modules =
    [
      ({
        modulesPath,
        ...
      }: {
        nixpkgs.hostPlatform = pkgs.system;
        imports = ["${modulesPath}/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"];
        isoImage.squashfsCompression = "zstd -Xcompression-level 6";
      })
    ]
    ++ (builtins.attrValues modules)
    ++ (builtins.attrValues {
      inherit
        (iliPresets.hive)
        base
        yubikey
        ;
      inherit
        (iliPresets)
        nix
        openssh
        ;
    });
}).config.system.build.isoImage
