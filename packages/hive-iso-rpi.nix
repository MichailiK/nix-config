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
    nodes = {};
  };
  modules =
    [
      ({
        modulesPath,
        lib,
        ...
      }: {
        nixpkgs.hostPlatform = "aarch64-linux";
        imports = ["${modulesPath}/installer/sd-card/sd-image-raspberrypi-installer.nix"];
        #sdImage.squashfsCompression = "zstd -Xcompression-level 6";
        networking.useDHCP = lib.mkForce true;
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
}).config.system.build.sdImage
