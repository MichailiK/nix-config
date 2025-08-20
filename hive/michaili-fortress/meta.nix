{iliPresets, ...}: {
  imports = builtins.attrValues {
    inherit
      (iliPresets.hive)
      base
      keepassxc
      yubikey
      ;
    inherit
      (iliPresets)
      comma
      nix
      desktop
      short-wireless
      ;
  };
}
