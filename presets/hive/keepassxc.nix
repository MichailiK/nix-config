# KeePassXC utilities for the default user.
# Note that ~/.local/share/ili/{keepassxc-db.kdbx,keepassxc-db-password.gpg}
# will need to be copied from somewhere.
{
  pkgs,
  iliPackages,
  ...
}: {
  mich.meta.defaultUser.packages = [
    pkgs.keepassxc
    iliPackages.keepassxc-ili
  ];
}
