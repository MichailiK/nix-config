# Hive

The hive contains all the systems/nodes for this flake.

## Nodes

The directories inside this directory are considered nodes/systems/hosts.
All nix files within the directory (excluding [meta.nix](#meta.nix) and
any excluded files it defines) are treated as modules & automatically imported.
The nodes are exposed to all [deployment tools](#tooling) implemented in this
flake, e.g. `nixosConfigurations`/`nixos-switch`.

### Create new

To make a new node in the hive, simply create a directory for it in the `nodes`
directory (ideally named after the node's hostname.)
It will automatically get picked up in deployment tools (e.g. `nixos-rebuild`).

Remember that flakes only consider staged/committed git files, make sure you
`git add` files before trying to apply a configuration.

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

## Tooling

The hive has been designed to be agnostic to deployment tools/methods.

Currently, two deployment tools/methods are implemented:
- The usual `nixosConfigurations` found in most flakes
- [wire](https://github.com/forallsys/wire)

See [tools README](./tools/README.md) for more info or how to integrate other
deployment tools/methods.
