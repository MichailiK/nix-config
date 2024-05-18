# Michaili's Nix Config

This is my early & in-development iteration of a NixOS configuration.
This configuration currently consists of only one Desktop PC, but has been
somewhat built up in a way that it can hopefully be easily expanded to
multiple systems.

## Notes and Issues

- There is currently only one machine in this configuration, to which where
  I dump all my options in. Sharing some of these options (e.g. users)
  will be a concern if I add another device.
- I've failed to use `users.users.<name>.hashedPasswordFile` and resulted in
  me getting locked out of my system once. The password doesn't seem to get
  written to `/etc/shadow`. Until I can figure out what the issue is, I'll have
  to leave `mutableUsers` on.
- There are several TODOs scattered across the configuration.
