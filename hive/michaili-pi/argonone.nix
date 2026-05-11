{
  lib,
  pkgs,
  ...
}: {
  boot.initrd.kernelModules = ["i2c-dev" "i2c-bcm2835"];
  boot.kernelModules = ["i2c-dev" "i2c-bcm2835"];
  hardware.i2c.enable = true;

  # turn off fan on boot
  systemd.services.argon-fan-off = {
    description = "Disable Argon ONE fan";
    after = ["multi-user.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.i2c-tools}/bin/i2cset -y 3 0x1a 0x00";
    };
  };

  /*
  systemd.services.argonone-fancontrold = let
    argonone-utils = pkgs.buildGoModule {
      name = "argonone-fancontrold";
      version = "0.1.0";

      src = pkgs.fetchFromGitHub {
        owner = "mgdm";
        repo = "argonone-utils";
        rev = "main";
        sha256 = "sha256-v098KH8TgzGgCc7+59SVWy19xW456eXX/BDdt9zzVhk=";
      };

      vendorHash = "sha256-0xhHGJEPFpwjRA03C8rpuZ2sIXU50+PS6ifTRMSrHKM=";
    };
  in {
    enable = true;
    wantedBy = ["default.target"];
    serviceConfig = {
      #DynamicUser = true;
      Group = "i2c";
      ExecStart = "${argonone-utils}/bin/argonone-fancontrold";
    };
  };
  */
}
