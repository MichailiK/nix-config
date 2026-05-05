{
  inputs = {
    nixpkgs-nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable-latest.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-unstable-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";
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

    ilib = import ./ilib {inherit inputs nixpkgs lib;};
    modules = import ./modules {inherit lib ilib;};
    iliPresets = import ./presets {inherit lib ilib;};
    iliPackages' = import ./packages {inherit inputs nixpkgs lib ilib modules iliPresets;};
    hive = ilib.hive.mkHive {
      nodeArgs = {
        defaultNixpkgs = nixpkgs;
        metaArgs = {inherit inputs nixpkgs lib ilib modules iliPresets iliPackages';};
        specialArgs = {inherit inputs nixpkgs lib ilib modules iliPresets iliPackages';};
        modules = builtins.attrValues modules;
      };
      directory = ./hive;
      predicate = name: !(lib.hasSuffix ".disabled" name);
    };
  in {
    formatter = ilib.forAllSystems (pkgs: pkgs.alejandra);
    devShells = ilib.forAllSystems (pkgs: {
      default = pkgs.mkShell {
        packages = builtins.attrValues {
          inherit (pkgs) alejandra;
          inherit (inputs.wire.packages.${pkgs.stdenv.hostPlatform.system}) wire-small;
        };
      };
    });
    nixosModules = modules;
    packages = ilib.forAllSystems (pkgs: iliPackages' pkgs);
    lib = ilib;

    # Hive-related attributes
    hive = hive;
    wire = ilib.hive.wire.constructHive hive;
    nixosConfigurations = ilib.hive.nixosConfigurations.constructHive hive;
  };
}
