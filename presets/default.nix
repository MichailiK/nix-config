{lib, ...}: let
  mkHiveAttr = path: exclude:
    lib.mapAttrs' (name: fileType:
      if (fileType == "directory")
      then lib.nameValuePair name (mkHiveAttr /${path}/${name} [])
      else if (fileType == "regular")
      then lib.nameValuePair (lib.removeSuffix ".nix" name) /${path}/${name}
      else builtins.throw "Unexpected file ${name} with file type ${fileType} in ${path}. Ensure that all files in the presets directory are only directories or files.")
    (builtins.removeAttrs (builtins.readDir path) exclude);
in
  mkHiveAttr ./. ["default.nix"]
