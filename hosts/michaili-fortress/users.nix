{ config, ... }:
{
  users = {
    # TODO turn off once the issue with hashedPasswordFile has been resolved
    mutableUsers = true;
  };
  mich.meta.defaultUser.extraGroups = [
    "libvirtd"
    "kvmfr"
  ];
}
