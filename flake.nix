{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs?ref=nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs?ref=nixpkgs-unstable";
    nixpkgs-unstable-small.url = "github:NixOS/nixpkgs?ref=nixos-unstable-small";
    colmena.url = "github:zhaofengli/colmena";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      colmena,
      ...
    }@inputs:
    let
      mapPkgsForEachSystem =
        callback:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (
          system: callback nixpkgs.legacyPackages.${system}
        );
    in
    {
      colmenaHive = colmena.lib.makeHive (import ./hive.nix inputs);
      formatter = mapPkgsForEachSystem (pkgs: pkgs.alejandra);
      devShells = mapPkgsForEachSystem (pkgs: {
        default = pkgs.mkShell {
          packages = builtins.attrValues {
            inherit (pkgs) alejandra;
            inherit (colmena.packages.${pkgs.system}) colmena;
          };
        };
      });
    };
}
