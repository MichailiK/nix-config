# Tooling

This config is made to be adaptable to various deployment tools, whether it's
the built-in `nixosConfigurations`/`nixos-rebuild`, or other deployment tools
available in the Nix/NixOS ecosystem.

## Add new deployment tool

Adding a new deployment tool should hopefully be fairly trivial. We will use
`nixosConfigurations`/`nixos-rebuild` as an example deployment tool we want to
implement.

You can either:
- Create a Nix file in this directory named after the deployment tool
- Create a sub-directory named after the deployment tool with a `default.nix`
  file.

In this case, just creating a file, `nixosConfigurations.nix` would be
sufficient.

The Nix file is expected to be a function taking an attrset
(the provided attributes are described below.)
The return value should be all the hive's nodes, in the data structure that your
deployment tool expects.

For `nixosConfigurations`, it wants an attrset of hostnames whose values are
`nixpkgs.lib.nixosSystem` invocations.

Your function will get the following arguments. The only crucial one is `nodes`,
the remainder are provided for convenience:
- `nodes`: The nodes of this hive. The structure of this attrset is describned below.
- `inputs`: Flake inputs. This is probably where you want to get your
  deployment tool's functions, modules, etc. from.
- `nixpkgs`: Default nixpkgs of this flake. Do not use this for the nodes,
  as each node may provide its own nixpkgs.
- `lib`: library functions provided by the default nixpkgs of this flake.
- `ilib`: library functions provided by this flake.
- `modules`: NixOS modules provided by this flake.
- `iliPresets`: Preset modules for this flake.
- `iliPackages'`: (Uninstantiated) packages of this flake.

### `nodes` data structure

Every node & their properties are automatically computed to help produce
consistent output across all deployment tools.
Each deployment tool is called with a `nodes` argument. It's an attrset of every
node in the hive. The values are an attrset containing:

- `modules`: a list NixOS modules that should be imported. This automatically
  includes all the Nix files of a hive (unless excluded via meta.nix)
  as well as all the NixOS modules of this flake.
- `nixpkgs`: the nixpkgs flake that should be used for this node.
- `specialArgs`: any special arguments that should be provided to the node.
  Note that the NixOS modules of this flake expect these args to be present.

Example:
```nix
{
  "michaili-fortress" = {
    modules = [
      /nix/store/...-source/hive/michaili-fortress/common.nix
      /nix/store/...-source/hive/michaili-fortress/desktop.nix
      { ... }
    ];
    nixpkgs = { _type: "flake"; lib = { ... }; ... }; # e.g. nixpkgs unstable
    specialArgs = {
      iliPackages' = «lambda @ ...»;
      iliPresets = { ... };
      ilib = { ... };
      inputs = { ... };
      my-node-specific-arg = "hello world";
    };
  };
  "raptor" = {
    modules = [ ... ];
    nixpkgs = { ... }; # e.g. nixpkgs latest stable
    specialArgs = { ... };
  };
  ...
}
```

### `nodes` special argument

Separately, you (or your deployment tool) are expected to expose the evaluated
NixOS configurations of all nodes, in the form of the `nodes` specialArgs.
Some modules, like the hive SSH modules, use this to learn the SSH host keys of
every node in this hive & automatically add them to the global `known_hosts` file.

There's various ways to accomplish such "recursive" attribute sets, such as:

```nix
# evalConfig = import "${nixpkgs.path}/nixos/lib/eval-config.nix";
let self = {
  michaili-fortress = evalConfig { specialArgs.nodes = self; ...; };
  raptor = evalConfig { specialArgs.nodes = self; ... };
}; in self;
```

or

```nix
# evalConfig = import "${nixpkgs.path}/nixos/lib/eval-config.nix";
lib.fix (self: {
  michaili-fortress = evalConfig { specialArgs.nodes = self; ...; };
  raptor = evalConfig { specialArgs.nodes = self; ... };
}) 
```

If you cannot do this, set `nodes` to an empty attrset, such as
`specialArgs.nodes = {};`.

### Implementation example

A working `nixosConfigurations` deployment tool implementation looks like this:

```nix
{
  nodes,
  lib,
  ...
}:
lib.fix (
  self:
    builtins.mapAttrs (name: value:
      value.nixpkgs.lib.nixosSystem {
        specialArgs = value.specialArgs // {nodes = self;};
        modules = value.modules
      })
    nodes
)
```

### Expose the data for the deployment tool

This will depend on the deployment tool you're using. The `flake.nix` at the root
of this repository imports the hive & deployment tools, you can then output
`hive.<deployment tool name>` wherever/however its needed.

In case of `nixosConfigurations`, it expects the `flake.nix` to have an attrset
called `nixosConfigurations` with all the hosts/nodes inside, so we will put
the output of our deployment tool there:

```diff
  inputs = { nixpkgs.url = "..."; ... };
  outputs = { ... }@args: let
    # ...
    hive = import ./hive {inherit inputs nixpkgs lib ilib modules iliPresets iliPackages';};
  in {
   # ...

   # Hive-related attributes
   _nodes = hive._nodes;
   wire = hive.wire;
+  nixosConfigurations = hive.nixosConfigurations;
  };
```

If we now check `nix flake show`, we should see all nodes of the hive listed:

```
$ nix flake show
git+file://...
├───nixosConfigurations
│   ├───michaili-fortress: NixOS configuration
│   └───raptor: NixOS configuration
└───wire: unknown
```

Now, regardless of whether you are using `wire`, `nixos-rebuild` or any other
deployment tool that's implemented, all tools should end up building the
(near) identical system.


### (Optional) add deployment tool to the flake's devShells

You may want to add the deployment tool to the `flake.nix`'s devShells.

It may look something like:

```diff
 devShells = ilib.forAllSystems (pkgs: {
   default = pkgs.mkShell {
     packages = builtins.attrValues {
       # ...
+      inherit (pkgs) nixos-rebuild;
+      # non-nixpkgs example: `inherit (inputs.wire.packages.${pkgs.system}) wire`
     };
   };
 });
```
