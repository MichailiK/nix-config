{
  inputs,
  nixpkgs,
  lib,
  ...
}:
lib.fix (self: let
  callLibs = file:
    import file {
      inherit inputs nixpkgs lib;
      ilib = self;
    };
in {
  trivial = callLibs ./trivial.nix;
  hive = callLibs ./hive;

  inherit
    (self.trivial)
    forAllSystems
    forAllSystemsOfNixpkgs
    pathFileType
    subDirectories
    mapSubDirectories
    listNixFilesInDirectory
    importNixInDirectory
    importNixInDirectory'
    ;
})
