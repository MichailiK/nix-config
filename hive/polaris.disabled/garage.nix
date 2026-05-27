{
  iliPresets,
  config,
  ...
}: {
  imports = [iliPresets.hive.garage];
  services.garage.settings = {
    rpc_public_addr = "${config.networking.fqdn}:3901";
    data_dir = [
      {
        capacity = "2T";
        path = "/storage/hdd1/garage";
      }
    ];
  };
}
