# KeePassXC utilities for the default user.
# Note that ~/.local/share/ili/{keepassxc-db.kdbx,keepassxc-db-password.gpg}
# will need to be copied from somewhere.
{
  pkgs,
  iliPkgs,
  ...
}: {
  mich.meta.defaultUser.packages = [
    pkgs.keepassxc
    iliPkgs.keepassxc-ili
  ];
}
