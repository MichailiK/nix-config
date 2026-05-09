{iliPresets, ...}: {
  mich.hive = {
    ssh = {
      knowNodesPublicKeys = true;
      trustedWithAgentForwarding = false;
      publicKeys = [
      ];
    };
  };

  networking.hostName = "polaris";
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
