{iliPresets, ...}: {
  imports = builtins.attrValues {
    inherit
      (iliPresets.hive)
      base
      keepassxc
      restic
      yubikey
      ;
    inherit
      (iliPresets)
      comma
      nix
      desktop
      short-wireless
      openssh
      ;
  };
}
