{iliPresets, ...}: {
  imports = builtins.attrValues {
    inherit
      (iliPresets.desktop)
      kde
      ;
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
      short-wireless
      openssh
      ;
  };
}
