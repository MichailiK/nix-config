{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../yubikey.nix
  ];
  systemd.user.tmpfiles.users.${config.mich.meta.defaultUser.name}.rules =
    lib.mkIf config.programs.git.enable
    (
      let
        file = pkgs.writeText "${config.mich.meta.defaultUser.name}_gitconfig" ''
          [commit]
          gpgSign = true

          [gpg]
          format = "openpgp"

          [gpg "openpgp"]
          program = "${lib.getExe' pkgs.gnupg "gpg"}"

          [tag]
          gpgSign = true

          [user]
          email = "git@michaili.dev"
          name = "Michaili K"
          signingKey = "870407F9D274E6BA"

        '';
      in [
        "L+ %h/.config/git/config - - - - ${file}"
      ]
    );
}
