{
  inputs,
  nixpkgs,
  lib,
  ilib,
  ...
}:
lib.fix (self: let
  callTool = file:
    import file {
      inherit inputs nixpkgs lib ilib;
      hive = self;
    };
in {
  # generates a a consistent representation of a node, to be used by
  # deployment tools.
  # this is a curried function, which expects:
  # - attrset that consist of various options/settings (see below)
  # - path to the directory, which has the node's NixOS modules/files/etc.
  #
  # all nix files inside the directory are considered to be NixOS modules and get
  # imported, unless excluded via the `excludeImports` argument.
  #
  # this function returns an attrset with the following attributes:
  # - nixpkgs: which (flake input) nixpkgs to use for this node
  # - specialArgs: special args to pass down to this node
  # - modules: which modules to import for this node
  mkNode = {
    defaultNixpkgs, # the default nixpkgs to use
    metaPath ? /meta.nix, # (relative) path the special meta nix file
    metaArgs ? {}, # arguments to pass down to the meta nix file
    excludeImports ? [], # fileset to exclude from auto imports. metaPath is always excluded.
    specialArgs ? {}, # specialArgs to pass down to the node
    modules ? [], # additional modules to import
  }: directory: let
    name = builtins.baseNameOf directory;
    meta =
      if (metaPath != null && builtins.pathExists /${directory}/${metaPath})
      then (import /${directory}/${metaPath} metaArgs)
      else {};
    nodeNixpkgs = meta.nixpkgs or defaultNixpkgs;
  in {
    # The nixpkgs this node should be evaluated with.
    nixpkgs = nodeNixpkgs;

    # The specialArgs that should be used for this node.
    specialArgs = specialArgs // (meta.specialArgs or {});

    # Modules the node consists of. Excludes special files like `metaPath`
    modules =
      (let
        excludeFileSet = lib.pipe excludeImports [
          (v: [v] ++ (meta.excludeImports or []))
          lib.flatten
          lib.fileset.unions
          # Also exclude meta path
          (lib.fileset.union (lib.fileset.maybeMissing /${directory}/${metaPath}))
        ];
      in
        lib.pipe /${directory} [
          (lib.fileset.fileFilter ({hasExt, ...}: hasExt "nix"))
          (fileSet: lib.fileset.difference fileSet excludeFileSet)
          lib.fileset.toList
        ])
      # Any imports declared in the meta.nix
      ++ (meta.imports or [])
      # Include all modules
      ++ modules
      # A module that sets the hostname to the directory name by default
      ++ [({lib, ...}: {config.networking.hostName = lib.mkDefault name;})];
  };

  # Creates an attrset of nodes using the subdirectories of the specified path.
  mkHive = {
    # node arguments as required from `mkNode` above
    nodeArgs,
    directory,
    # Predicate for excluding nodes/sub-directories.
    # For example, to to exclude nodes that end with .disabled:
    # `name: !(lib.hasSuffix ".disabled" name)`
    predicate ? null,
  }: let
    subdirs = ilib.subDirectories directory;
    filteredSubdirs =
      if (predicate != null)
      then builtins.filter predicate subdirs
      else subdirs;
  in
    lib.genAttrs filteredSubdirs (nodeDir: self.mkNode nodeArgs /${directory}/${nodeDir});

  nixosConfigurations = callTool ./nixosConfigurations.nix;
  wire = callTool ./wire.nix;
})
