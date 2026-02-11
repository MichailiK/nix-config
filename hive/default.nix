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
  nodes = import ./nodes args;
  toolArgs = args // {inherit nodes;};
in
  (builtins.mapAttrs (_: tool: tool toolArgs) (ilib.importNixInDirectory ./tools)) // {_nodes = nodes;}
