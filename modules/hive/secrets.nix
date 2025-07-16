{
  lib,
  config,
  name,
  ...
}:
let
  inherit (lib) mkOption mkEnableOption types;
in
{
  options.mich.secrets = {
    includeLocalSecrets = mkEnableOption "Whether to automatically include secrets in your hosts/\${name}/secrets directory.";

    globalSecrets = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config.deployment.keys = lib.mkMerge [
    # Local/host specific secrets
    (lib.mkIf config.mich.secrets.includeLocalSecrets (
      lib.listToAttrs (
        map (path: {
          name = lib.removePrefix "./" "${lib.path.removePrefix ../../hosts/${name}/secrets path}";
          value = {
            keyCommand = [
              "gpg"
              "--decrypt"
              "${path}"
            ];
          };
        }) (lib.fileset.toList ../../hosts/${name}/secrets)
      )
    ))

    # Global/shared secrets
    (lib.listToAttrs (
      map (secretName: {
        name = "global/${secretName}";
        value = {
          keyCommand = [
            "gpg"
            "--decrypt"
            "${../../secrets/${secretName}}"
          ];
        };
      }) config.mich.secrets.globalSecrets
    ))
  ];

}
