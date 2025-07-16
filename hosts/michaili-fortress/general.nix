{
  pkgs,
  ...
}: {

  mich.secrets.includeLocalSecrets = true;
  #mich.secrets.globalSecrets = ["funny-shared-secret"];

  boot.supportedFilesystems = ["ntfs"];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;


  services = {
    openssh.enable = true;
    tailscale = {
      enable = true;
      openFirewall = true;
      authKeyFile = "/run/keys/tailscale-key";
    };
  };

  #environment.extraInit = ''
  #  export SSH_AUTH_SOCK=$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)
  #'';

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
