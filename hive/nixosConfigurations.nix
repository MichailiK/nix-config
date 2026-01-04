{
  nodes,
  inputs,
  nixpkgs,
  lib,
  ilib,
  modules,
  iliPresets,
  iliPackages',
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
              # use directory name as hostname by default
              config.networking.hostName = lib.mkDefault name;
            })
          ];
      })
    nodes
)
