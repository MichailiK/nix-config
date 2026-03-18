{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options.mich.xdg-autostart = {
    packages = mkOption {
      default = [];
      type = types.listOf types.package;
      description = ''
        xdg-autostart desktop entries to add to all users.
        expects packages with /share/applications/ desktop entries
      '';
    };
    users = mkOption {
      default = {};
      type = types.attrsOf (types.submodule {
        options = {
          packages = mkOption {
            default = [];
            type = types.listOf types.package;
            description = ''
              xdg-autostart desktop entries to add to this user.
              expects packages with /share/applications/ desktop entries
            '';
          };
        };
      });
    };
  };

  config = let
    cfg = config.mich.xdg-autostart;

    # takes a list of packages and turns them into a derivation with XDG autostart entries.
    mkXdgAutoStartPackage = packages:
      pkgs.runCommandLocal "xdg-autostart-entries"
      {PACKAGES_PATHS = lib.makeSearchPath "share/applications" packages;}
      ''
        mkdir -p "$out"/etc/xdg/autostart

        IFS=: # Split by colon
        for dir in $PACKAGES_PATHS; do
          [ -d "$dir" ] || continue # Skip if package does not have /share/applications/
          find "$dir" -maxdepth 1 -type f -exec ln -sf {} "$out/etc/xdg/autostart/" \;
        done
      '';

    usersWithPackages = builtins.filter (name: (builtins.length cfg.users.${name}.packages) > 0) (builtins.attrNames cfg.users);
  in {
    environment.systemPackages = lib.optionals (builtins.length cfg.packages > 0) [(mkXdgAutoStartPackage cfg.packages)];
    users.users = lib.genAttrs usersWithPackages (name: {
      packages = [(mkXdgAutoStartPackage cfg.users.${name}.packages)];
    });
  };
}
