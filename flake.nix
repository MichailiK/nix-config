{
  inputs = {
    nixpkgs-nixos-unstable.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable-latest.url = "github:NixOS/nixpkgs?ref=nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs?ref=nixpkgs-unstable";
    nixpkgs-unstable-small.url = "github:NixOS/nixpkgs?ref=nixos-unstable-small";
    colmena.url = "github:zhaofengli/colmena";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-nixos-unstable";
    };
  };
  outputs = {
    self,
    ...
  } @ inputs: let
    # The default/de-facto nixpkgs for this flake
    nixpkgs = inputs.nixpkgs-nixos-unstable;

    lib = nixpkgs.lib;
    ilib = import ./ilib.nix {inherit lib nixpkgs;};
    modules = import ./modules {inherit lib ilib;};
    iliPresets = import ./presets {inherit lib ilib;};
  in {
    colmenaHive = import ./hive {inherit inputs nixpkgs ilib modules iliPresets;};
    formatter = ilib.forAllSystems (pkgs: pkgs.alejandra);
    devShells = ilib.forAllSystems (pkgs: {
      default = pkgs.mkShell {
        packages = builtins.attrValues {
          inherit (pkgs) alejandra;
          inherit (inputs.colmena.packages.${pkgs.system}) colmena;
        };
      };
    });
    nixosModules = modules;
    packages = ilib.forAllSystems (pkgs: import ./packages {inherit pkgs nixpkgs inputs ilib modules iliPresets;});
    lib = ilib;
  };
}
