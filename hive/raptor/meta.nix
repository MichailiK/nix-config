{
  nixpkgs-stable-latest,
  iliPresets,
  ...
}: {
  nixpkgs = import nixpkgs-stable-latest {system = "x86_64-linux";};
  imports = builtins.attrValues {
    inherit
      (iliPresets.hive)
      base
      ;
    inherit
      (iliPresets)
      nix
      openssh
      ;
  };
}
