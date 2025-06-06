{
  pkgs,
  inputs,
  ...
}: {

  imports = [
    inputs.nix-index-database.nixosModules.nix-index
  ];
  programs.nix-index-database.comma.enable = true;

  ili.secrets.includeLocalSecrets = true;
  #ili.secrets.globalSecrets = ["funny-shared-secret"];

  boot.plymouth.enable = true;
  boot.plymouth.theme = "spinner";

  boot.supportedFilesystems = ["ntfs"];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.sane = {
    enable = true;
    extraBackends = [pkgs.sane-airscan];
  };

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

  environment.extraInit = ''
    export SSH_AUTH_SOCK=$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)
  '';

  fonts.enableDefaultPackages = true;

  networking.hostName = "michaili-fortress";
  networking.networkmanager.enable = true;

  # TODO might want to default this to UTC for other hosts
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = builtins.attrValues {
    inherit
      (pkgs)
      wget
      wl-clipboard
      ;
    nil = inputs.nil.packages.${pkgs.system}.default;
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}
