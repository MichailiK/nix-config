{
  pkgs,
  inputs,
  ...
}: {

  imports = [
    inputs.nix-index-database.nixosModules.nix-index
  ];
  programs.nix-index-database.comma.enable = true;

  mich.secrets.includeLocalSecrets = true;
  #mich.secrets.globalSecrets = ["funny-shared-secret"];

  boot.plymouth.enable = true;
  boot.plymouth.theme = "spinner";

  boot.supportedFilesystems = ["ntfs"];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.sane = {
    enable = true;
    extraBackends = [pkgs.sane-airscan];
  };

  # TODO test
  security.pam.rssh.enable = true;

  services = {
    openssh.enable = true;
    printing.enable = true;
    tailscale = {
      enable = true;
      openFirewall = true;
      authKeyFile = "/run/keys/tailscale-key";
    };
  };

  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
      configure = {
        packages.myVimPackages = with pkgs.vimPlugins; {
          start = [vim-wayland-clipboard];
        };
      };
    };

    direnv.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    git = {
      enable = true;
      lfs.enable = true;
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
      ;
    nil = inputs.nil.packages.${pkgs.system}.default;
  };
}
