{
  inputs,
  nixpkgs,
  lib,
  ilib,
  modules,
  iliPresets,
  iliPackages',
  ...
} @ args: let
  nodes = import ./nodes.nix args;
in {
  wire = import ./wire.nix (args // {inherit nodes;});
  nixosConfigurations = import ./nixosConfigurations.nix (args // {inherit nodes;});
}
