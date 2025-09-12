{
  inputs,
  nixpkgs,
  modules,
  ilib,
  iliPresets,
  ...
}: let
  colmena = inputs.colmena;
  lib = nixpkgs.lib;
  instantiatedNixpkgs = import nixpkgs {
    system = "x86_64-linux";
    overlays = [];
  };
  nodes = (import ./nodes.nix) {
    inherit inputs lib ilib iliPresets;
    nixpkgs = instantiatedNixpkgs;
  };
in
  colmena.lib.makeHive (
    {
      meta = {
        nixpkgs = instantiatedNixpkgs;

        # Use the nixpkgs the node has provided in its meta.nix
        nodeNixpkgs = lib.pipe nodes [
          (lib.filterAttrs (name: value: value.nixpkgs != null))
          (builtins.mapAttrs (name: value: value.nixpkgs))
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
        imports =
          # Import all modules of our own flake
          lib.flatten (builtins.attrValues modules);
        
        # Colmena doesn't inject this yet
        # https://github.com/NixOS/nixpkgs/blob/40c7c335458e1a4a0a961f684d0395ff59a9b8ac/flake.nix#L89
        config.nixpkgs.flake.source = builtins.toString pkgs.path;

        config.networking.hostName = lib.mkDefault name;
        config.deployment = {
          allowLocalDeployment = lib.mkDefault true;
          buildOnTarget = lib.mkDefault true;
          targetHost = let
            sshConfig = config.mich.meta.ssh;
          in
            lib.mkDefault (
              if (!sshConfig.enable)
              then null
              else if (sshConfig.hostName != null)
              then sshConfig.hostName
              else (builtins.head sshConfig.host)
            );
          targetUser = lib.mkDefault config.mich.meta.defaultUser.name;
        };
      };
    }
    // (
      # Add all nodes into this attrset for Colmena to recognize
      builtins.mapAttrs (
        name: node: {
          # Import all the identified modules of the node
          imports = node.modules;
        }
      )
      nodes
    )
  )
