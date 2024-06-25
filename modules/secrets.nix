{lib, ...}: let
  inherit (lib) mkOption mkEnableOption types;
in {
  options.ili.secrets = {
    includeLocalSecrets = mkEnableOption "Secrets to be included in your hosts/\${name}/secrets directory.";

    globalSecrets = mkOption {
      type = types.listOf types.str;
      default = [];
    };
  };
}
