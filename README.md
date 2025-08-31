# Michaili's Nix Config

My Nix config for my various NixOS nodes. Uses [Colmena] for deployment.

Some of the highlights & interesting things in this flake:

- The `hive` NixOS module has `mich.meta.ssh` options. These allow sharing
  sharing public SSH keys between colmena nodes, giving every machine a shared
  SSH known_hosts file.
- Each node may have a special `meta.nix` file for providing information
  without evaluating the node.
  For example, the `meta.nix` may provide a specific nixpkgs branch to evaluate
  the node with.
- Various `presets` nodes can make use of, allowing the right level of granuality

[Colmena]: https://github.com/zhaofengli/colmena