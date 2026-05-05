{
  nixpkgs,
  lib,
  ...
}:
lib.fix (self: {
  # Maps all systems. useful for flake outputs
  forAllSystems = callback: self.forAllSystemsOfNixpkgs nixpkgs callback;

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
      self.subDirectories
      (builtins.map (v: {
        name = v;
        value = function v;
      }))
      builtins.listToAttrs
    ];

  # Traverses through all (sub-)directories filtering for .nix files and
  # returns them in a flat list. useful to import them all as modules
  listNixFilesInDirectory = path: lib.fileset.toList (lib.fileset.fileFilter ({hasExt, ...}: hasExt "nix") path);

  importNixInDirectory = path: self.importNixInDirectory' [] path;
  importNixInDirectory' = exclude: path:
    lib.pipe path [
      builtins.readDir
      (contents: builtins.removeAttrs contents exclude)
      (lib.filterAttrs (
        name: fileType:
          (fileType == "regular" && lib.hasSuffix ".nix" name)
          || (fileType == "directory" && builtins.pathExists /${path}/${name}/default.nix)
      ))
      (lib.mapAttrs'
        (
          name: fileType:
            lib.nameValuePair
            (
              if (fileType == "regular")
              then (lib.removeSuffix ".nix" name)
              else name
            )
            (import /${path}/${name})
        ))
    ];
})
