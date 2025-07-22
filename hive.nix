{
  nixpkgs,
  ...
}@inputs:
builtins.mapAttrs (
  name: fileType:
  assert nixpkgs.lib.asserts.assertMsg (fileType == "directory") ''
    There is an unexpected ${fileType} file (${name}) inside the hosts directory.
    Everything in the hosts directory must be directories.
  '';
  { }
) (builtins.readDir ./hosts)
// {
  meta = {
    nixpkgs = import nixpkgs {
      system = "x86_64-linux";
      overlays = [ ];
    };
    specialArgs = {
      inherit inputs;
      rootPath = ./.;
    };
  };
  defaults =
    {
      name,
      config,
      lib,
      ...
    }:
    {
      imports = lib.flatten [
        # ./hosts/${name}/**/*.nix
        (lib.filter (filePath: lib.hasSuffix ".nix" filePath) (lib.fileset.toList ./hosts/${name}))
        # ./modules/**/*.nix
        (lib.filter (filePath: lib.hasSuffix ".nix" filePath) (lib.fileset.toList ./modules))
      ];
      config.networking.hostName = lib.mkDefault name;
      config.deployment = {
        allowLocalDeployment = lib.mkDefault true;
        buildOnTarget = lib.mkDefault true;
        targetHost =
          let
            sshConfig = config.mich.meta.ssh;
          in
          lib.mkDefault (
            if (!sshConfig.enable) then
              null
            else if (sshConfig.hostName != null) then
              sshConfig.hostName
            else
              (builtins.head sshConfig.host)
          );
        targetUser = lib.mkDefault config.mich.meta.defaultUser.name;
      };
    };
}
