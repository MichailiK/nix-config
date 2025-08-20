{
  lib,
  ilib,
  ...
}:
lib.pipe ./. [
  ilib.subDirectories
  (builtins.map (directory: {
    name = directory;
    value = {
      # If a module/subdirectory has a default.nix file, only import that.
      # Otherwise import all nix files.
      imports =
        if (ilib.pathFileType ./${directory}/default.nix == "regular")
        then [./${directory}/default.nix]
        else ilib.listNixFilesInDirectory ./${directory};
    };
  }))
  builtins.listToAttrs
]
