{pkgs, ...}@args: let
  lib = pkgs.lib;
in
  lib.pipe ./. [
    builtins.readDir
    (
      lib.filterAttrs (
        fileName: fileType:
          (fileName != "default.nix")
          && (fileType != "symlink")
          && (fileType != "regular" || (lib.hasSuffix ".nix" fileName))
      )
    )
    (lib.mapAttrs' (fileName: fileType: {
      name =
        if (fileType == "regular")
        then lib.removeSuffix ".nix" fileName
        else fileName;
      value = import ./${fileName} args;
    }))
  ]
