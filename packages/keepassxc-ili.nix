# KeePassXC utilities for the default user.
# Note that ~/.local/share/ili/{keepassxc-db.kdbx,keepassxc-db-password.gpg}
# will need to be copied from somewhere.
{
  lib,
  stdenvNoCC,
  gnupg,
  keepassxc,
  writeShellScript,
  makeDesktopItem,
  copyDesktopItems,
  ...
}: let
  keepassxc-wrap =
    writeShellScript "keepassxc-ili"
    ''
      BASE_DIR="''${XDG_DATA_HOME:-$HOME/.local/share}"/ili
      ${lib.getExe gnupg} --decrypt "$BASE_DIR"/keepassxc-db-password.gpg | ${lib.getExe keepassxc} --pw-stdin "$BASE_DIR"/keepassxc-db.kdbx
    '';
  keepassxc-cli-wrap =
    writeShellScript "keepassxc-cli-ili"
    ''
      BASE_DIR="''${XDG_DATA_HOME:-$HOME/.local/share}"/ili
      ${lib.getExe gnupg} --quiet --decrypt "$BASE_DIR"/keepassxc-db-password.gpg | ${lib.getExe' keepassxc "keepassxc-cli"} "$1" "$BASE_DIR"/keepassxc-db.kdbx "''${@:2}"
    '';
in
  stdenvNoCC.mkDerivation {
    pname = "keepassxc-ili";
    version = keepassxc.version;

    dontUnpack = true;

    installPhase = ''
      runHook preInstall

      mkdir -p "$out"/bin
      ln -s "${keepassxc-wrap}" "$out"/bin/keepassxc-ili
      ln -s "${keepassxc-cli-wrap}" "$out"/bin/keepassxc-cli-ili

      runHook postInstall
    '';

    nativeBuildInputs = [copyDesktopItems];
    desktopItems = [
      (makeDesktopItem {
        name = "keepassxc-ili";
        desktopName = "KeePassXC ili Database";
        exec = "keepassxc-ili";
        comment = "Launches KeePassXC with the ili database. Master password decrypted using gpg.";
        icon = "keepassxc";
        categories = ["Utility" "Security" "Qt"];
      })
    ];
  }
