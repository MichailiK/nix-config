{
  nodes,
  inputs,
  nixpkgs,
  lib,
  ilib,
  modules,
  iliPresets,
  iliPackages,
  ...
}:
lib.fix (
  self:
    builtins.mapAttrs (name: value:
      value.nixpkgs.lib.nixosSystem {
        specialArgs = value.specialArgs // {nodes = self;};
        modules =
          value.modules
          ++ [
            ({lib, ...}: {
              # defaults
              config.networking.hostName = lib.mkDefault name;
            })
          ];
      })
    nodes
)
