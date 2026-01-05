# To use these packages, you must pass an (instantiated) nixpkgs
{lib, ...} @ args: pkgs:
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
  (
    v:
      lib.fix (
        self:
          lib.mapAttrs' (fileName: fileType: {
            name =
              if (fileType == "regular")
              then lib.removeSuffix ".nix" fileName
              else fileName;
            value = pkgs.callPackage ./${fileName} (args // self);
          })
          v
      )
  )
]
