{lib, ...}: {
  constructNode = node:
    node.nixpkgs.lib.nixosSystem {
      specialArgs = node.specialArgs;
      modules =
        node.modules
        ++ (lib.optionals node.deployToolOpt [
          {
            imports = [./deployToolOpt.nix];
            config.mich.deployTool = "nixosConfigurations";
          }
        ]);
    };

  constructHive = nodes:
    lib.fix (
      self:
        builtins.mapAttrs (name: value:
          value.nixpkgs.lib.nixosSystem {
            specialArgs = value.specialArgs // {nodes = self;};
            modules =
              value.modules
              ++ (lib.optionals value.deployToolOpt [
                {
                  imports = [./deployToolOpt.nix];
                  config.mich.deployTool = "nixosConfigurations";
                }
              ]);
          })
        nodes
    );
}
