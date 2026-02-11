# KeePassXC utilities for the default user.
# Note that ~/.local/share/ili/{keepassxc-db.kdbx,keepassxc-db-password.gpg}
# will need to be copied from somewhere.
{
  config,
  pkgs,
  iliPkgs,
  ...
}: {
  mich.meta.defaultUser.packages = [
    pkgs.keepassxc
    # This might not be a great idea because this could be sequoia chameleon,
    # sequoia cannot make use of GUI pinentry tools (yet?) and this package
    # contains a desktop application that invokes a gpg command.
    (iliPkgs.keepassxc-ili.override {gnupg = config.programs.gnupg.package;})
  ];
}
