{iliPresets, ...}: {
  imports = [iliPresets.hive.garage];
  services.garage.settings = {
    data_dir = [
      {
        capacity = "1T";
        path = "/storage/hdd1/garage";
      }
    ];

    s3_api = {
      api_bind_addr = "/run/garage/s3.sock";
      s3_region = "garage";
    };
    admin = {
      api_bind_addr = "/run/garage/admin.sock";
      metrics_require_token = true;
    };
  };

  systemd.services.garage.serviceConfig = {
    RuntimeDirectory = "garage";
  };
}
