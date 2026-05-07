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

      rpc_secret_file = lib.mkIf (rpcSecretPath != null) rpcSecretPath;
      rpc_bind_addr = "[::]:3901";
      bootstrap_peers = [
        #"todo@osprey.michai.li:3901"
      ];
    };
    extraEnvironment = {
      RUST_BACKTRACE = "1";
    };
  };

  users.users.garage = {
    isSystemUser = true;
    group = "garage";
  };
  users.groups.garage = {};
}
