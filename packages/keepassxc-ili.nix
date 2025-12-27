# KeePassXC utilities for the default user.
# Note that ~/.local/share/ili/{keepassxc-db.kdbx,keepassxc-db-password.gpg}
# will need to be copied from somewhere.
{pkgs, ...}: let
  keepassxc-wrap =
    pkgs.writeShellScript "keepassxc-ili"
    ''
      BASE_DIR="''${XDG_DATA_HOME:-$HOME/.local/share}"/ili
      ${pkgs.lib.getExe pkgs.gnupg} --decrypt "$BASE_DIR"/keepassxc-db-password.gpg | ${pkgs.lib.getExe pkgs.keepassxc} --pw-stdin "$BASE_DIR"/keepassxc-db.kdbx
    '';
  keepassxc-cli-wrap =
    pkgs.writeShellScript "keepassxc-cli-ili"
    ''
      BASE_DIR="''${XDG_DATA_HOME:-$HOME/.local/share}"/ili
      ${pkgs.lib.getExe pkgs.gnupg} --quiet --decrypt "$BASE_DIR"/keepassxc-db-password.gpg | ${pkgs.lib.getExe' pkgs.keepassxc "keepassxc-cli"} "$1" "$BASE_DIR"/keepassxc-db.kdbx "''${@:2}"
    '';
in
  pkgs.stdenvNoCC.mkDerivation {
    name = "keepassxc-ili";
    version = pkgs.keepassxc.version;

    dontUnpack = true;

    installPhase = ''
      runHook preInstall

      mkdir -p "$out"/bin
      ln -s "${keepassxc-wrap}" "$out"/bin/keepassxc-ili
      ln -s "${keepassxc-cli-wrap}" "$out"/bin/keepassxc-cli-ili

      runHook postInstall
    '';

    nativeBuildInputs = [pkgs.copyDesktopItems];
    desktopItems = [
      (pkgs.makeDesktopItem {
        name = "keepassxc-ili";
        desktopName = "KeePassXC ili Database";
        exec = "keepassxc-ili";
        comment = "Launches KeePassXC with the ili database. Master password decrypted using gpg.";
        icon = "keepassxc";
        categories = ["Utility" "Security" "Qt"];
      })
    ];
  }
