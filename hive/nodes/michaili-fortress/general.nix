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

  environment.systemPackages = builtins.attrValues {
    inherit
      (pkgs)
      wget
      wl-clipboard
      nil
      ;
  };
}
