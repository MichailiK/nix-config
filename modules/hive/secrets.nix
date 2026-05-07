{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.mich.hive.secrets;
in {
  # Secrets assume wire's NixOps(-like) secrets scheme for now.
  options.mich.hive.secrets = {
    present = mkOption {
      type = types.bool;
      description = "Whether secrets are present";
      readOnly = true;
    };
    toolSupport = mkOption {
      type = types.bool;
      description = "Whether the tool supports secrets";
      default = (config.mich.deployTool or null) == "wire";
      readOnly = true;
    };
    available = mkOption {
      type = types.bool;
      description = "Whether secrets are available (i.e. secrets are present & the tool supports them)";
      readOnly = true;
    };
    paths = mkOption {
      type = types.attrsOf types.str;
      readOnly = true;
    };
    owner = mkOption {
      type = types.attrsOf types.str;
      default = {};
    };
  };

  config = {
    mich.hive.secrets.available = cfg.present && cfg.toolSupprt;

    system.switch.inhibitors = {
      "mich-hive-secrets-available" =
        if cfg.present && cfg.toolSupport
        then "true"
        else "false";
    };
  };
}
