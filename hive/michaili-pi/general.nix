{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  environment.systemPackages = builtins.attrValues {
    inherit
      (pkgs)
      libraspberrypi
      raspberrypi-eeprom
      ;
  };

  boot.kernelParams = ["zswap.enabled=1" "zswap.shrinker_enabled=1"];
  boot.initrd.systemd.enable = true;

  security.sudo = {
    wheelNeedsPassword = false;
    execWheelOnly = true;
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };
  #services.getty.autologinUser = config.mich.hive.defaultUser.name;
  networking = {
    useDHCP = true;
    useNetworkd = true;
    firewall.logRefusedConnections = false;
    firewall.extraCommands = ''
      iptables -A INPUT -p udp --dport 33434:33534 -j REJECT --reject-with icmp-port-unreachable
      ip6tables -A INPUT -p udp --dport 33434:33534 -j REJECT --reject-with icmp6-port-unreachable
    '';
  };
  systemd.network = {
    # view in `networkctl status <interface>`
    config.networkConfig.SpeedMeter = true;
    enable = true;
  };
}
