# Hive

The hive contains all the systems/nodes for this flake, as well as how to
deploy changes to the nodes.

## Nodes

The `nodes` directory contain all the nodes/systems/hosts this hive hosts.
Each node has its own directory, and all nix files within their directories
(excluding [meta.nix](#meta.nix) and any excluded files it defines) are treated
as NixOS modules & automatically imported.

## Deployment Tools

The `tools` directory contains implementations of deploymnt.
Currently, two tools are implemented:

- The usual `nixosConfigurations`/`nixos-rebuild` found in most flakes
- [wire](https://github.com/forallsys/wire)

This means that, when creating a node, you are able to build & deploy it
using either `nixos-rebuild` or `wire`.

See [tools `README`](./tools/README.md) for more info or how to integrate other
deployment tools/methods.

## Create new node

To make a new node in the hive, simply create a directory for it in the `nodes`
directory (ideally named after the node's hostname.)
It will automatically get picked up in deployment tools (e.g. `nixos-rebuild`).

(Remember that flakes only consider staged/committed git files, make sure you
`git add` files before trying to build/apply.)

### meta.nix

`meta.nix` is treated as a special file, which allows a specific node to
provide some metadata/information prior to evaluating its modules.

`meta.nix` should be a function that can expect to receive all of the flake's
inputs as well as some utilities like `lib` and `ilib`. It should return
an attribute set that may contain:

- `nixpkgs`: A specific nixpkgs flake to use
- `imports`: any additional modules to import
- `specialArgs`: any specialArgs to add to the node
- `excludeImports`: list of [fileset](https://nixos.org/manual/nixpkgs/unstable/#sec-functions-library-fileset)
  or list of paths which get excluded from automatic import.

All attributes are optional.

Example:

```nix
{ nixpkgs-latest-stable, iliPresets, ... }: {
  nixpkgs = nixpkgs-latest-stable;
  imports = builtins.attrValues {
    inherit
      (iliPresets.hive)
      base
      yubikey
      ;
    inherit
      (iliPresets)
      flakes
      ;
  };
  specialArgs = {
    something = "abc";
    utils = import ./utilities.nix; 
  };
  excludeImports = [ ./domains ./utilities.nix ];
}
```
