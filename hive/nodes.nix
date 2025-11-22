{
  inputs,
  nixpkgs,
  lib,
  ilib,
  iliPresets,
  ...
}: let
  # These are "special files" that should not be treated as Nix modules
  # and thus must not be imported with the module system.
  specialFiles = [
    "meta.nix"
  ];
in
  ilib.mapSubDirectories (directory: let
    meta =
      if (builtins.pathExists ./${directory}/meta.nix)
      then (import ./${directory}/meta.nix (inputs // {inherit lib ilib iliPresets;}))
      else {};
  in {
    # The nixpkgs this node should be evaluated with.
    # Null if the hive's default nixpkgs should be used.
    nixpkgs =
      if (meta ? nixpkgs)
      then meta.nixpkgs
      else null;

    # The specialArgs that should be used for this node
    specialArgs =
      if (!(meta ? specialArgs))
      then null
      else if (builtins.isFunction meta.specialArgs)
      then
        meta.specialArgs {
          inherit inputs ilib iliPresets;
          nixpkgs =
            if (meta ? nixpkgs)
            then meta.nixpkgs
            else nixpkgs;
        }
      else meta.specialArgs;

    modules =
      # Modules the node consists of. Excludes special files like `meta.nix`
      (let
        metaExcludedImports =
          if (!(meta ? excludeImports))
          then []
          else meta.excludeImports;
        specialFileSet = lib.pipe specialFiles [
          (builtins.map (path: ./${directory}/${path}))
          (builtins.map lib.fileset.maybeMissing)
          # Also exclude files that are ignored in meta.nix
          (v: v ++ metaExcludedImports)
          lib.fileset.unions
        ];
      in
        lib.pipe ./${directory} [
          (lib.fileset.fileFilter ({hasExt, ...}: hasExt "nix"))
          (fileSet: lib.fileset.difference fileSet specialFileSet)
          lib.fileset.toList
        ])
      # Any imports declared in the meta.nix
      ++ (
        if meta ? imports
        then meta.imports
        else []
      );
  })
  ./.
