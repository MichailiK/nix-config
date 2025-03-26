{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs?ref=nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    nil,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;
    mapPkgsForEachSystem = callback:
      nixpkgs.lib.genAttrs
      nixpkgs.lib.systems.flakeExposed
      (system: callback nixpkgs.legacyPackages.${system});
  in {
    colmena = {
      meta = {
        nixpkgs = import nixpkgs {
          # TODO also build for other systems where needed
          system = "x86_64-linux";
        };
        specialArgs = {inherit inputs;};
      };
      michaili-fortress.deployment = {
        allowLocalDeployment = true;
        #buildOnTarget = true;
        targetHost = null; # TODO Remove when multiple personal devices are being introduced to the config
        # see README for why this is commented out
        /*
        keys.users-michaili-password = {
               # TODO might not want to ship secrets as part of this Git repo
               keyCommand = ["gpg" "--decrypt" "${./secrets/users-michaili-password}"];
             };
        */
        #keys."michaili-fortress/tailscale-key".keyCommand = [ "gpg" "--decrypt" "${./secrets/michaili-fortress/tailscale-key.gpg}" ];
      };
      defaults = {
        name,
        config,
        ...
      }: {
        imports = lib.flatten [
          (lib.filter (filePath: lib.hasSuffix ".nix" filePath) (lib.fileset.toList ./hosts/${name}))
          ./modules/secrets.nix
          home-manager.nixosModules.home-manager
        ];
        deployment = {
          keys = lib.mkMerge [
            # Local/host specific secrets
            (lib.mkIf
              config.ili.secrets.includeLocalSecrets
              (lib.listToAttrs (map (path: {
                name = lib.removePrefix "./" "${lib.path.removePrefix ./hosts/${name}/secrets path}";
                value = {
                  keyCommand = ["gpg" "--decrypt" "${path}"];
                };
              }) (lib.fileset.toList ./hosts/${name}/secrets))))

            # Global/shared secrets
            (lib.listToAttrs (map (secretName: {
                name = "global/${secretName}";
                value = {
                  keyCommand = ["gpg" "--decrypt" "${./secrets/${secretName}}"];
                };
              })
              config.ili.secrets.globalSecrets))
          ];
        };
      };
    };
    formatter = mapPkgsForEachSystem (pkgs: pkgs.alejandra);
    devShells = mapPkgsForEachSystem (pkgs: {
      default = pkgs.mkShell {
        packages = builtins.attrValues {
          inherit
            (pkgs)
            colmena
            alejandra
            ;
        };
      };
    });
  };
}
