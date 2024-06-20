{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs?ref=nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };
  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
  } @ inputs: let
    lib = nixpkgs.lib;
    mapPkgsForEachSystem = callback:
      nixpkgs.lib.genAttrs
      [ "x86_64-linux" "aarch64-linux" ]
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
      };
      defaults = {name, ...}: {
        imports = lib.flatten [
          (lib.filter (filePath: lib.hasSuffix ".nix" filePath) (lib.fileset.toList ./hosts/${name}))
          home-manager.nixosModules.home-manager
        ];
      };
    };
    packages = mapPkgsForEachSystem (pkgs: {
      airgap-iso = import ./pkgs/airgap-iso.nix { nixpkgs = nixpkgs; systempkgs = pkgs; };
    });
    devShells = mapPkgsForEachSystem (pkgs: {
      default = pkgs.mkShell {
        packages = with pkgs; [colmena alejandra];
      };
    });
  };
}
