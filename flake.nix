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
  outputs = {
    self,
    nixpkgs,
    colmena,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;
    ilib = import ./ilib.nix {inherit lib nixpkgs;};
    modules = import ./modules {inherit lib ilib;};
    iliPresets = import ./presets {inherit lib ilib;};
  in {
    colmenaHive = import ./hive {inherit inputs ilib modules iliPresets;};
    formatter = ilib.forAllSystems (pkgs: pkgs.alejandra);
    devShells = ilib.forAllSystems (pkgs: {
      default = pkgs.mkShell {
        packages = builtins.attrValues {
          inherit (pkgs) alejandra;
          inherit (colmena.packages.${pkgs.system}) colmena;
        };
      };
    });
    nixosModules = modules;
    lib = ilib;
  };
}
