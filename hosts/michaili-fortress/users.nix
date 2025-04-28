{pkgs, ...}: {
  # TODO do I want to share this user across all my systems?
  users = {
    # TODO turn off once the issue with hashedPasswordFile has been resolved
    mutableUsers = true;
    users.michaili = {
      isNormalUser = true;
      extraGroups = ["wheel" "libvirtd" "kvmfr"];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOct0GpSUGR8eFXiyPF6rHFQ9r97rdH/+rv/GDZnSyqS openpgp:0x5E718B7B"
      ];
      # See README on why this is commented out
      # hashedPasswordFile = "/run/keys/users-michaili-password";
    };
  };
  home-manager.users.michaili = {pkgs, ...}: {
    programs = {
      git = {
        enable = true;
        difftastic.enable = true;
        signing = {
          key = "870407F9D274E6BA";
          signByDefault = true;
        };
        userName = "Michaili K";
        userEmail = "git@michaili.dev";
      };
      vscode = {
        enable = true;
        package = pkgs.vscodium-fhs;
      };
    };
    home.stateVersion = "23.11";
  };
}
