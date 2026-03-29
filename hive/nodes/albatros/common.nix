{iliPresets, ...}: {
  mich.meta = {
    ssh = {
      knowNodesPublicKeys = true;
      trustedWithAgentForwarding = true;
      publicKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC7fHJANvJn0bThBKxb9ZG+25+MZgyunBTSirg8s7srq"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCSwdI+8CEJAdzYVfmtR2BxNSmrp+ueqKyvhcN0uVZGI1Hr5uTTL9D6i6T7RdB11uTXGhrRyK3odDv/8J2iQG5XNm+K8x2kf1ivsUmAdsnU8tOMjQehdbp02OOBef/ZPiujiWtE/7uAC4e4WoBxtjS2mwW52ubiRUbyVj19NpejQPx/24Rh8bUlD6CutfjvyXZNteAs6f3H9P2TdhIa2cZQzz8u4GJhCVgNR/d+iDYG+i2Rc/8t04Dzopesk0GjfrmM15ROhVRLXH80d00KkE99xPYn4HQUNvvLh3+7JVHLrUUAXm8eQfJ2OmgoPewg+KfwYG8j/girdZaTee6/JtkOODxWmQF406lrlU/tFmfvMtbmFOupWCyS6MSu5teTauICNncStDk/8kDI9wZIO5UT7TB3EbVV2HztzVviKkZLICN06z0xnTUVpYmL6XgXhbOcvmsrq6xCZWkEILB4tPASSlp73mUX6fz1dWXIzSK9ZlIh6J6hMuuEWJLx+vWZDZlyUDc5ewNf7RW0e31eEdWkcxoXeC6n8Mc7Qh17yRzSMWQK5w8+faBF34pzvIUBe+A0D83Me77uUx26mzcNO6fTc7I0KbrK/Xp6Ag1mNcvO9nSAvD7zvzh6OINVh/nkaCbj205Hr9igNRt38fi6fON81MqF8pRUsiwLAV8UwyumUw=="
      ];
    };
  };

  networking.hostName = "albatros";
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

  system.stateVersion = "25.11";
}
