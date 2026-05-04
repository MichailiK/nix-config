{iliPresets, ...}: {
  mich.meta = {
    ssh = {
      knowNodesPublicKeys = true;
      trustedWithAgentForwarding = true;
      publicKeys = [];
    };
  };

  networking.hostName = "osprey";
  networking.domain = "michai.li";
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  imports = builtins.attrValues {
    inherit
      (iliPresets.hive)
      base
      ;
    inherit
      (iliPresets)
      nix
      openssh
      comma
      ;
  };

  system.stateVersion = "26.05";
}
