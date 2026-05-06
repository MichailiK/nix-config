{
  inputs,
  nixpkgs,
  lib,
  ...
}: let
  wire = inputs.wire;
in {
  constructNode = builtins.throw "The wire deployment tool does not support constructing singular nodes";

  constructHive = nodes:
    wire.makeHive (
      {
        meta = {
          # TODO figure out a nicer way around this
          nixpkgs = import nixpkgs {
            system = "x86_64-linux";
            overlays = [];
          };

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
        };

        defaults = {
          name,
          config,
          lib,
          pkgs,
          options,
          ...
        }: {
          # wire deployment specific configuration
          config.deployment = {
            allowLocalDeployment = lib.mkDefault true;
            buildOnTarget = lib.mkDefault true;
            target = lib.mkIf (lib.hasAttrByPath ["mich" "hive"] options) {
              host = let
                sshConfig = config.mich.hive.ssh;
              in
                lib.mkDefault (
                  if (!sshConfig.enable)
                  then null
                  else sshConfig.host
                );
              user = lib.mkDefault config.mich.hive.defaultUser.name;
            };
          };
        };
      }
      // (
        # Add all nodes into this attrset for wire to recognize
        builtins.mapAttrs (name: node: {
          # Import all the identified modules of the node
          imports =
            node.modules
            ++ (lib.optionals node.deployToolOpt [
              {
                imports = [./deployToolOpt.nix];
                config.mich.deployTool = "wire";
              }
            ]);
        })
        nodes
      )
    );
}
