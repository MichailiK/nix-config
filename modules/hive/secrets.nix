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
      default = false;
      readOnly = true;
    };
    toolSupport = mkOption {
      type = types.bool;
      description = "Whether the tool supports secrets";
      default = false;
      readOnly = true;
    };
    available = mkOption {
      type = types.bool;
      description = "Whether secrets are available (i.e. secrets are present & the tool supports them)";
      default = cfg.present && cfg.toolSupport;
      readOnly = true;
    };
    paths = mkOption {
      type = types.attrsOf types.str;
      default = {};
      readOnly = true;
    };
  };

  config = let
    hasToolSupport = (config.mich.deployTool or null) == "wire";
  in {
    mich.hive.secrets.available = cfg.present && hasToolSupport;

    system.switch.inhibitors = {
      "mich-hive-secrets-available" =
        if cfg.present && cfg.toolSupport
        then "true"
        else "false";
    };
  };
}
