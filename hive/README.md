# Hive

## New nodes

To make a new node in the hive, simply create a directory for it, ideally
named after the node's hostname. It will automatically get picked up.

## Special files

### `meta.nix`

`meta.nix` is treated as a special file, which allows a specific node to
provide some metadata/information prior to evaluating its modules.

`meta.nix` should be a function that can expect to receive all of the flake's
inputs as well as some utilities like `lib` and `ilib`. It should return
an attribute set that may contain:

- `nixpkgs`: A specific nixpkgs instance to use
- `imports`: any additional modules to import
- `specialArgs`: any specialArgs to add to the node
- `excludeImports`: list of [fileset](https://nixos.org/manual/nixpkgs/unstable/#sec-functions-library-fileset)
  or list of paths which get excluded from imports.

All attributes are optional.

Example:

```nix
{ nixpkgs-stable, iliPresets, ... }: {
  nixpkgs = import nixpkgs-stable { system = "x86_64-linux"; };
  imports = builtins.attrValues {
    inherit
      (iliPresets.hive)
      base
      yubikey
      ;
    inherit
      (iliPresets)
      flakes
      desktop
      ;
  };
  specialArgs = {
    something = "abc";
  };
  excludeImports = [ ./domains ];
}
```
