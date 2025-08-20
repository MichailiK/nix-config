{
  nixpkgs-stable,
  iliPresets,
  ...
}: {
  nixpkgs = import nixpkgs-stable {system = "x86_64-linux";};
  imports = builtins.attrValues {
    inherit
      (iliPresets.hive)
      base
      ;
    inherit
      (iliPresets)
      nix
      ;
  };
}
