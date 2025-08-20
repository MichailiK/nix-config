{...}: {
  mich.meta.defaultUser.extraGroups = ["libvirtd"];

  security.sudo.wheelNeedsPassword = false;
  security.sudo.execWheelOnly = true;

  boot = {
    swraid.enable = true;
    loader = {
      efi.canTouchEfiVariables = false;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        efiInstallAsRemovable = true;
      };
    };
  };

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  networking.firewall.logRefusedConnections = false;

  systemd.services.sshd = {
    serviceConfig.LogFilterPatterns = [
      "Invalid user [^\s]+ from [^\s]+ port [0-9]+$"
      "Disconnected from invalid user [^\s]+ \[preauth\]$"
      "Connection closed by invalid user [^\s]+ \[preauth\]$"
    ];
  };
  systemd.services.sshd-session.serviceConfig.LogFilterPatterns = [
    "Invalid user [^\s]+ from [^\s]+ port [0-9]+$"
  ];

  networking = {
    useDHCP = false;
    usePredictableInterfaceNames = true;
  };

  fileSystems = {
    "/" = {
      device = "/dev/lvm-data/root";
      fsType = "btrfs";
      options = [
        "compress=zstd:3"
        "discard=async"
        "ssd"
      ];
    };
    "/boot" = {
      device = "/dev/md/raptor:boot";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
    "/nix" = {
      device = "/dev/lvm-data/nix";
      fsType = "btrfs";
      options = [
        "compress=zstd:5"
        "discard=async"
        "ssd"
      ];
    };
    "/home" = {
      device = "/dev/lvm-data/home";
      fsType = "btrfs";
      options = [
        "compress=zstd:3"
        "discard=async"
        "ssd"
      ];
    };
    "/var" = {
      device = "/dev/lvm-data/var";
      fsType = "btrfs";
      options = [
        "compress=zstd:5"
        "discard=async"
        "ssd"
      ];
    };
  };

  systemd.network = {
    enable = true;
    networks."internet" = {
      matchConfig = {
        MACAddress = "50:eb:f6:2f:36:10";
      };
      dns = [
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
        "1.1.1.1"
        "1.0.0.1"
      ];
      addresses = [
        {Address = "78.46.83.238/27";}
        {Address = "2a01:4f8:120:11e6::1/64";}
      ];
      routes = [
        {Gateway = "78.46.83.225";}
        {Gateway = "fe80::1";}
      ];
    };
  };
}
