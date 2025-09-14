{
  nixpkgs-stable-latest,
  iliPresets,
  ...
}: {
  # Wait for next nixpkgs stable release as it relies on Kea 3.0 stuff
  #nixpkgs = import nixpkgs-stable-latest {system = "x86_64-linux";};
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
