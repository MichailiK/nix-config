# Tooling

This config is made to be adaptable to various deployment tools, whether it's
the built-in `nixosConfigurations`/`nixos-rebuild`, or other deployment tools
which the community has made.

## Nodes data structure

Each deployment tool gets a `nodes` argument passed down. It is an attrset
consisting of all the nodes/systems of this hive. The values of it is an(other)
attrset with these attributes:

- `modules`: a list NixOS modules that should be automatically imported.
  This automatically includes all the nix files of a hive
  (unless excluded via meta.nix) as well as all the NixOS modules of this flake.
- `nixpkgs`: the nixpkgs flake that should be used for this machine.
- `specialArgs`: any special arguments that should be provided to the node.
  Note that the NixOS modules of this flake expect these arguments to be present.

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
      my-special-arg = "hello world";
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

## Add new deployment tool

Adding a new deployment tool should hopefully be fairly trivial. We will use
`nixosConfigurations`/`nixos-rebuild` as an example.

### 1. Implement deployment tool

Create a Nix file in this directory where you will implement the deployment tool.
This example could be called `nixosConfigurations.nix`.

You will need to implement a function (that we will call in `default.nix` later)
which returns the nodes in the data structure your deployment tool expects.
For `nixosConfigurations`, it wants an attrset of hostnames whose values are
`nixpkgs.lib.nixosSystem` invocations.

Your function will get the following arguments. The only crucial one is `nodes`,
the remainder are provided for convenience:
- `nodes`: The nodes of this hive. The structure of this attrset is describned
  in the section above.
- `inputs`: Flake inputs. This is probably where you want to get your
  deployment tool's functions, modules, etc. from
- `nixpkgs`: Default nixpkgs of this flake. Do not use this for the nodes,
  as each node may provide its own nixpkgs.
- `lib`: nixpkgs libraries
- `ilib`: libraries provided by this flake
- `modules`: NixOS modules provided by this flake
- `iliPresets`: Preset modules for this flake
- `iliPackages'`: (Uninstantiated) packages of this flake.

You or your deployment tool are expected to do two special things:
- You should set the hostname to the node's name by yourself, like
  `config.networking.hostName = lib.mkDefault name;`
- You should provide a `nodes` specialArgs which contains the NixOS configurations
  of all nodes in this hive. Some things like the hive SSH modules use this to learn
  the SSH host keys of all nodes in this hive & automatically add them to the known_hosts.
  
  There's various ways to accomplish such "recursive" attribute sets, such as:
  
   - `let self = { michaili-fortress = { specialArgs.nodes = self; }; raptor = { ... }; } in self;`
   - `lib.fix (self: { michaili-fortress = { specialArgs.nodes = self; }; raptor = {...}; })`
  
  If you cannot do this, set `nodes` to an empty attrset, like `specialArgs = { nodes = {}; };`.

Example:

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
        modules =
          value.modules
          ++ [
            ({lib, ...}: { config.networking.hostName = lib.mkDefault name; })
          ];
      })
    nodes
)
```

### 2. Import deployment tool in `default.nix`

Should be pretty straight forward, head to the `default.nix` and add an attribute
for your deployment tool & import it:

```diff
  { ... }@args: let
    nodes = import ./nodes.nix args;
  in {
    wire = import ./wire.nix (args // {inherit nodes;});
+   nixosConfigurations = import ./nixosConfigurations.nix (args // {inherit nodes;});
  }
```

### 3. Expose attribute.

This will depend on the deployment tool you're using. In case of `nixosConfigurations`,
it wants for the Flake to have an attrset called `nixosConfigurations`
with all the hosts/nodes inside, so we will put our nodes there:

```diff
  inputs = { nixpkgs.url = "..."; ... };
  outputs = { ... }@args: let
    # ...
    hive = import ./hive {inherit inputs nixpkgs lib ilib modules iliPresets iliPackages';};
  in {
   wire = hive.wire;
+  nixosConfigurations = hive.nixosConfigurations;
   # ...
  };
```

Now if we check `nix flake show`, we should see our nodes:
```
$ nix flake show
git+file://...
├───nixosConfigurations
│   ├───michaili-fortress: NixOS configuration
│   └───raptor: NixOS configuration
└───wire: unknown
```
