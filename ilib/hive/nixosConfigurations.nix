{lib, ...}: {
  constructNode = node:
    node.nixpkgs.lib.nixosSystem {
      specialArgs = node.specialArgs;
      modules = node.modules;
    };

  constructHive = nodes:
    lib.fix (
      self:
        builtins.mapAttrs (name: value:
          value.nixpkgs.lib.nixosSystem {
            specialArgs = value.specialArgs // {nodes = self;};
            modules = value.modules;
          })
        nodes
    );
}
