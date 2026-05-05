# Hive

This directory contains all the systems/nodes for this flake.

Each node has its own directory, and all nix files within their directories
(excluding the [meta file](#meta-file) and any excluded files it defines) are
treated as NixOS modules & automatically imported.

## Deployment Tools

Two tools are implemented:

- The usual `nixosConfigurations`/`nixos-rebuild` found in most flakes
- [wire](https://github.com/forallsys/wire)

This means that, when creating or updating a node's configuration, you are able
to build & deploy changes using either `nixos-rebuild` or `wire`.

## Create new node

To make a new node in the hive, simply create a directory for it in the `nodes`
directory (ideally named after the node's hostname.) & start creating Nix files.
The new node will get automatically picked up in deployment tools.

> Remember that flakes only consider staged/committed git files, make sure you
> `git add` files before trying to build/apply.

### Meta file

The meta file (`meta.nix`) is treated as a special file, which allows a specific
node to provide some metadata/information prior to evaluating its modules.

`meta.nix` should contain a function that can expect to receive all of the
flake's inputs as well as some utilities like `lib` and `ilib`. It should return
an attribute set that may contain:

- `nixpkgs`: A specific nixpkgs flake to use
- `imports`: any additional modules to import
- `specialArgs`: any specialArgs to add to the node
- `excludeImports`: a [fileset](https://nixos.org/manual/nixpkgs/unstable/#sec-functions-library-fileset)
  or list of paths which get excluded from automatic import.

All attributes are optional.

Example:

```nix
{ inputs, nixpkgs-latest-stable, iliPresets, ... }: {
  nixpkgs = nixpkgs-latest-stable;
  imports = [ inputs.foobar.nixosModules.default ];
  specialArgs = {
    something = "abc";
    utils = import ./utilities.nix; 
  };
  excludeImports = [ ./domains ./utilities.nix ];
}
```
