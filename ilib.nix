{
  nixpkgs,
  lib,
  ...
}: rec {
  # Maps all systems. useful for flake outputs
  forAllSystems = callback: forAllSystemsOfNixpkgs nixpkgs callback;

  forAllSystemsOfNixpkgs = nixpkgs: callback:
    lib.genAttrs lib.systems.flakeExposed (
      system: callback nixpkgs.legacyPackages.${system}
  );

  # "Safe" version of builtins.readFileType that returns null if a path doesnt exist.
  pathFileType = path:
    if (builtins.pathExists path)
    then builtins.readFileType path
    else null;

  # List the directories of a specified path.
  subDirectories = path:
    lib.pipe (builtins.readDir path) [
      (lib.filterAttrs (name: fileType: fileType == "directory"))
      builtins.attrNames
    ];

  # Map subdirectories of a path to an attrset, whose name is the directory name
  # and the value is the return value of the function.
  mapSubDirectories = function: path:
    lib.pipe path [
      subDirectories
      (builtins.map (v: {
        name = v;
        value = function v;
      }))
      builtins.listToAttrs
    ];

  # Traverses through all (sub-)directories filtering for .nix files and
  # returns them in a flat list. useful to import them all as modules
  listNixFilesInDirectory = path: lib.fileset.toList (lib.fileset.fileFilter ({hasExt, ...}: hasExt "nix") path);
}
