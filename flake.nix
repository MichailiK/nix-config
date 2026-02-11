{
  inputs = {
    nixpkgs-nixos-unstable.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable-latest.url = "github:NixOS/nixpkgs?ref=nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs?ref=nixpkgs-unstable";
    nixpkgs-unstable-small.url = "github:NixOS/nixpkgs?ref=nixos-unstable-small";
    wire.url = "github:forallsys/wire/trunk";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-nixos-unstable";
    };
  };
  outputs = {self, ...} @ inputs: let
    # The default/de-facto nixpkgs for this flake
    nixpkgs = inputs.nixpkgs-nixos-unstable;
    lib = nixpkgs.lib;

    ilib = import ./ilib.nix {inherit nixpkgs lib;};
    modules = import ./modules {inherit lib ilib;};
    iliPresets = import ./presets {inherit lib ilib;};
    iliPackages' = import ./packages {inherit inputs nixpkgs lib ilib modules iliPresets;};
    hive = import ./hive {inherit inputs nixpkgs lib ilib modules iliPresets iliPackages';};
  in {
    formatter = ilib.forAllSystems (pkgs: pkgs.alejandra);
    devShells = ilib.forAllSystems (pkgs: {
      default = pkgs.mkShell {
        packages = builtins.attrValues {
          inherit (pkgs) alejandra;
          inherit (inputs.wire.packages.${pkgs.system}) wire-small;
        };
      };
    });
    nixosModules = modules;
    packages = ilib.forAllSystems (pkgs: iliPackages' pkgs);
    lib = ilib;

    # Hive-related attributes
    _nodes = hive._nodes;
    wire = hive.wire;
    nixosConfigurations = hive.nixosConfigurations;
  };
}
