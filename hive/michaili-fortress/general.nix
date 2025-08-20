{pkgs, ...}: {
  boot.supportedFilesystems = ["ntfs"];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    tailscale = {
      enable = true;
      openFirewall = true;
    };
  };

  fonts.enableDefaultPackages = true;

  networking.networkmanager.enable = true;

  environment.systemPackages = builtins.attrValues {
    inherit
      (pkgs)
      wget
      wl-clipboard
      nil
      ;
  };
}
