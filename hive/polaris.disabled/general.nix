{config, ...}: {
  boot.loader.systemd-boot.enable = true;

  boot.kernelParams = ["zswap.enabled=1" "zswap.shrinker_enabled=1"];
  boot.initrd.systemd.enable = true;

  security.sudo.wheelNeedsPassword = false;

  services.getty.autologinUser = config.mich.hive.defaultUser.name;

  networking.useDHCP = false;
  systemd.network = {
    # view in `networkctl status <interface>`
    config.networkConfig.SpeedMeter = true;
    networks = {
      internet = {
        matchConfig = {
          MACAddress = "bc:24:11:11:3f:fa";
        };
        dns = [
          "2606:4700:4700::1111" # Cloudflare IPv6 primary
          "2606:4700:4700::1001" # Cloudflare IPv6 secondary
          "1.1.1.1" # Cloudflare IPv4 primary
          "1.0.0.1" # Cloudflare IPv4 secondary
        ];
        addresses = [
          {Address = "38.49.217.220/27";} # polaris.michai.li
          {Address = "2602:ffd5:754:1::2/64";} # polaris.michai.li
        ];
        routes = [
          {Gateway = "38.49.217.193";}
          {Gateway = "2602:ffd5:754:1::1";}
        ];
        cakeConfig = {
          Bandwidth = "1G";
          FlowIsolationMode = "dual-src-host"; # fairness is applied over source IPs first, then flows within them.
        };
      };
    };
  };
}
