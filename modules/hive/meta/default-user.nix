{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
in {
  # The default user to create with wheel permissions etc.
  options.mich.meta.defaultUser = {
    name = mkOption {type = types.str;};
    description = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    wheel = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to grant the default user the wheel group";
    };
    extraGroups = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Additional groups to add to the default user";
    };
    authorizedKeys = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "The authorized SSH keys for the default user.";
    };
    packages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Packages to add to the default user";
    };
  };

  config.users.users = lib.mkIf (config.mich.meta.defaultUser.name != null) (let
    inherit
      (config.mich.meta.defaultUser)
      name
      description
      wheel
      extraGroups
      authorizedKeys
      packages
      ;
  in {
    ${name} = {
      inherit name description packages;
      isNormalUser = true;
      extraGroups = lib.optionals wheel ["wheel"] ++ extraGroups;
      openssh.authorizedKeys.keys = authorizedKeys;
    };
  });
}
