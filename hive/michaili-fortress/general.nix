{pkgs, ...}: {
  boot.supportedFilesystems = ["ntfs"];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
