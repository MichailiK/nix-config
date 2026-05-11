{
  iliPresets,
  lib,
  ...
}: {
  deployment = {
    allowLocalDeployment = false;
    buildOnTarget = false;
  };
  mich.hive = {
    ssh = {
      knowNodesPublicKeys = true;
      trustedWithAgentForwarding = false;
      publicKeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCa7eCwJ5BQcLQKbXg1bQlvNRNON3OZ9wePilS0rHVQNCcyXZuwe/aLioSHfkeDrBFsL2ejd69KdoN5jFegUKFqQCVQd5J3yE5QetbfP47SDII1Y9pjy6N4n+I1ola8VAbTTAevJ2INGbO+/UYwX27v6HX79E6T6PmwFwypusLkthz/PrKDFbj6VJ5MhER5Q5chQptVLVd894rGccTS99wd2FhTV+82fu8LpK8inBPZpHZe5eIFOGotL/3MdimdRg/EotFFMRrhHK1yHvard9H0G/6FK97wZpPRwmUm1I9oUmBq6hrllOvJzk0q2cjxwxeuo5sIs6pcfg78YzyV3G2cdTEi7ag13wLHV2knHcNafE8ROL4s5uB2/zO5s5YE94TGHe1K2DqQxR/D+wqzl7eUFAAcELu0kbjBish4qVkLNYx4rwqoKBa41qUnoaiSvuxaK5nooUweL4G6S4Pop5k65LNEzHeyQoBAKlZc5RKv0X0P0CGHSzhp0m2pqRxhcH1XXqwJwWccowgA0Ss851LTBt3wmPa3DnFYE2V1jUc+jQWpGeEI1Zz6uejv9sM3FVKgG34zZcvDMA4zRLkyM8LZD72BbsWvFFzevn4UJ+e8i8VGPUgfoaCfUtObRB7SrbzJBz4b80/pUVd5unJcUqGXCtKWqsFs8wdPM+lXwkoEeQ=="
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
      ;
  };

  system.stateVersion = "26.05";
}
