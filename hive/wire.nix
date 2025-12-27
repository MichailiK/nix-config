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
}: let
  wire = inputs.wire;
  instantiatedNixpkgs = import nixpkgs {
    system = "x86_64-linux";
    overlays = [];
  };
in
  wire.makeHive (
    {
      meta = {
        nixpkgs = instantiatedNixpkgs;

        # Use the nixpkgs the node has provided in its meta.nix
        nodeNixpkgs = lib.pipe nodes [
          (lib.filterAttrs (name: value: value.nixpkgs != null))
          (builtins.mapAttrs (name: value: import value.nixpkgs {system = "x86_64-linux";}))
        ];

        # Add any specialArgs the node has provided in its meta.nix
        nodeSpecialArgs = lib.pipe nodes [
          (lib.filterAttrs (name: value: value.specialArgs != null))
          (builtins.mapAttrs (name: value: value.specialArgs))
        ];

        specialArgs = {
          inherit inputs ilib;
        };
      };

      defaults = {
        name,
        config,
        lib,
        pkgs,
        ...
      }: {
        # use directory name as hostname by default
        config.networking.hostName = lib.mkDefault name;
        # wire deployment specific configuration
        config.deployment = {
          allowLocalDeployment = lib.mkDefault true;
          buildOnTarget = lib.mkDefault true;
          target = {
            host = let
              sshConfig = config.mich.meta.ssh;
            in
              lib.mkDefault (
                if (!sshConfig.enable)
                then null
                else sshConfig.host
              );
            user = lib.mkDefault config.mich.meta.defaultUser.name;
          };
        };
      };
    }
    // (
      # Add all nodes into this attrset for wire to recognize
      builtins.mapAttrs (name: node: {
        # Import all the identified modules of the node
        imports = node.modules;
      })
      nodes
    )
  )
