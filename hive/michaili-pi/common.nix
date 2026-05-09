{iliPresets, ...}: {
  mich.hive = {
    ssh = {
      knowNodesPublicKeys = true;
      trustedWithAgentForwarding = false;
      publicKeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDkxFX17+xFol941SoYAtBdk0N/3hpHOWsPBpXMpFSHJjL2J53iXuf6ZtD982PbFDdvm82NGcByCirNYcDZKplW4zg9WaNVllaLV+okPlVZmlOuUoliJ/NkmKcNlqSsgeLjkht41X+gFtK9bTQkdRc7ZTlSRlE5PHZ74RwrSYpGr7ohujowlCMCrffbE4sp7TVQmSRPUkz3Kn5knQzjYXhaBSu+XenuWEZq9obvxVWKg2qdWx321iOczAPr0HPEDFKpW3PkqKeyrFXNsX/LXUIZQ+7FQMkQow9/OgyVvAQu6UB55E4xgv023ckYepv33PX9iXdq+bqcyDSrxvHAMg/T9YtTNai8peRSEzdFlS/jRTf1gerJeHRFtpaNjwKM2n97JnV9iAlnfjGF6OGaEP8OMEu8ePfnEzUD+Cb0d/DsqwtU0qxgjOrSGhBbueGc1qpqTBcOfOr7zwm4Oeiw9z6DWiRTjucWoNwbVsPFTqu+8K5RD3CtjMK3mgT5ZFd5bu58WipaRMnZ54/X/Nw8CQRT+JpsC/cchWyKbsUVHlw1nH4170hldRDowa48tst2gtD52jV8RO+Ms46FSDzbZ60aHqK3F6UJ0+P29eTy67Unk01zJSCZhVCTA27b39vwmv5MbK97GstoersbE7NnU/N+9tAAUXkSoN8o6/1SrTXRZQ=="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPjjTBg0GZzp5abPL7kzMghjgZ07pkckGLU0TW9pZEB5"
      ];
    };
  };

  networking.hostName = "michaili-pi";
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
