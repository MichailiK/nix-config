{
  iliPresets,
  config,
  ...
}: {
  imports = [iliPresets.hive.garage];
  services.garage.settings = {
    data_dir = [
      {
        capacity = "2T";
        path = "/storage/hdd1/garage";
      }
    ];
    metadata_dir = "/storage/ssd1/garage";
  };
}
