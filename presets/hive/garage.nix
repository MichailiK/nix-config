{
  config,
  pkgs,
  lib,
  ...
}: let
  rpcSecretPath = config.mich.hive.secrets.paths."garage-rpc-secret" or null;
in {
  mich.hive.secrets.owner."garage-rpc-secret" = "garage";

  services.garage = lib.mkIf (rpcSecretPath != null) {
    enable = true;
    package = pkgs.garage_2;
    settings = {
      replication_factor = 3;
      consistency_mode = "consistent";

      db_engine = "lmdb";
      metadata_auto_snapshot_interval = "6h";

      block_size = "10M";

      rpc_secret_file = lib.mkIf (rpcSecretPath != null) rpcSecretPath;
      rpc_bind_addr = "[::]:3901";
      rpc_public_addr = "${config.networking.fqdn}:3901";

      s3_api = {
        s3_region = "garage";
      };
    };
    extraEnvironment = {
      RUST_BACKTRACE = "1";
    };
  };
  networking.firewall.allowedTCPPorts = [3901];
  systemd.services.garage.serviceConfig = lib.mkIf (rpcSecretPath != null) {
    DynamicUser = false;
    User = "garage";
    Group = "garage";
  };

  users.users.garage = {
    isSystemUser = true;
    group = "garage";
  };
  users.groups.garage = {};
}
