# this file gives deployment tools every node of this hive as an attrset.
# the values of the attrset is another attrset with the following attributes:
# - nixpkgs: which (flake input) nixpkgs to use for this node
# - specialArgs: special args to pass down to this node
# - modules: which modules to import for this node
#
# none of these values are null, and deployment tool implementations should
# always consume these values for consistency across multiple deployment tools.
{
  inputs,
  nixpkgs,
  lib,
  ilib,
  modules,
  iliPresets,
  iliPackages,
  ...
}: let
  # default nixpkgs to use for nodes if they dont define one
  defaultNixpkgs = nixpkgs;

  # Special args that should always be included by default
  # contains flake inputs, ilib, iliPresets and iliPacakges
  defaultSpecialArgs = {
    inherit inputs ilib iliPresets iliPackages;
  };

  # These are "special files" that should not be treated as Nix modules
  # and thus must not be imported with the module system.
  defaultSpecialFiles = [
    "meta.nix"
  ];

  # NixOS modules that should always be included
  # includes all the modules defined in this flake
  defaultModules = builtins.attrValues modules;
in
  ilib.mapSubDirectories (directory: let
    meta =
      if (builtins.pathExists ./${directory}/meta.nix)
      then (import ./${directory}/meta.nix (inputs // {inherit lib ilib iliPresets iliPackages;}))
      else {};
  in {
    # The nixpkgs this node should be evaluated with.
    # Null if the hive's default nixpkgs should be used.
    nixpkgs = meta.nixpkgs or defaultNixpkgs;

    # The specialArgs that should be used for this node.
    specialArgs = let
      args =
        if (!(meta ? specialArgs))
        then {}
        else if (builtins.isFunction meta.specialArgs)
        then
          meta.specialArgs {
            inherit inputs ilib iliPresets iliPackages;
            nixpkgs = meta.nixpkgs or defaultNixpkgs;
          }
        else meta.specialArgs;
    in
      args // defaultSpecialArgs;

    # Modules the node consists of. Excludes special files like `meta.nix`
    modules =
      (let
        metaExcludedImports = meta.excludeImports or [];
        specialFileSet = lib.pipe defaultSpecialFiles [
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
      ++ (meta.imports or [])
      # Include all modules in this flake
      ++ defaultModules;
  })
  ./.
