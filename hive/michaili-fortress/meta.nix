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
      audio-vst
      comma
      nix
      desktop
      short-wireless
      openssh
      ;
  };
}
