# Restic utilities for the default user
# Note that ~/.config/rclone/rclone.config will need to be copied from somewhere,
# As well as the ~/.local/share/ili/restic_secret.gpg
{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      restic
      rclone
      ;
  };
  mich.meta.defaultUser.packages = [
    (pkgs.writeShellScriptBin "restic-proton" ''
      RESTIC_REPOSITORY="rclone:proton:/restic/archive" \
      RESTIC_PASSWORD_COMMAND="${lib.getExe' pkgs.gnupg "gpg"} -d ~/.local/share/ili/restic_secret.gpg" \
      RCLONE_PASSWORD_COMMAND="${lib.getExe' pkgs.gnupg "gpg"} -d ~/.local/share/ili/rclone_secret.gpg" \
      exec "${lib.getExe pkgs.restic}" "$@"
    '')
  ];
}
