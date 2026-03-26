{pkgs, ...}: {
  boot.supportedFilesystems = ["ntfs"];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelParams = ["zswap.enabled=1" "zswap.shrinker_enabled=1"];
  boot.initrd.systemd.enable = true;

  services = {
    tailscale = {
      enable = true;
      openFirewall = true;
    };
  };

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
    };
  };

  environment.systemPackages = builtins.attrValues {
    inherit
      (pkgs)
      wget
      wl-clipboard
      nil
      ;
  };
}
