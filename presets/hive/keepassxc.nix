# KeePassXC utilities for the default user.
# Note that ~/.local/share/ili/{keepassxc-db.kdbx,keepassxc-db-password.gpg}
# will need to be copied from somewhere.
{pkgs, ...}: {
  mich.meta.defaultUser.packages = [
    pkgs.keepassxc
    # KeePassXC GUI
    (pkgs.stdenvNoCC.mkDerivation {
      name = "keepassxc-ili";
      src = pkgs.writeShellApplication {
        name = "keepassxc-ili-unwrapped";
        runtimeInputs = builtins.attrValues {
          inherit
            (pkgs)
            keepassxc
            gnupg
            ;
        };
        # TODO make KeePassXC quit when the screen gets locked
        # busctl --user call org.keepassxc.KeePassXC.MainWindow /keepassxc org.keepassxc.KeePassXC.MainWindow appExit
        text = ''
          BASE_DIR="''${XDG_DATA_HOME:-$HOME/.local/share}"/ili
          gpg --decrypt "$BASE_DIR"/keepassxc-db-password.gpg | keepassxc --pw-stdin "$BASE_DIR"/keepassxc-db.kdbx
        '';
      };

      installPhase = ''
        runHook preInstall

        mkdir -p $out/bin
        ln -s $src/bin/keepassxc-ili-unwrapped $out/bin/keepassxc-ili

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
    })
    # KeePassXC CLI
    (pkgs.writeShellApplication {
      name = "keepassxc-cli-ili";
      runtimeInputs = builtins.attrValues {
        inherit
          (pkgs)
          keepassxc
          gnupg
          ;
      };
      text = ''
        BASE_DIR="''${XDG_DATA_HOME:-$HOME/.local/share}"/ili
        gpg --quiet --decrypt "$BASE_DIR"/keepassxc-db-password.gpg | keepassxc-cli "$1" "$BASE_DIR"/keepassxc-db.kdbx "''${@:2}"
      '';
    })
  ];
}
