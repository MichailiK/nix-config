{iliPresets, ...}: {
  mich.hive = {
    ssh = {
      knowNodesPublicKeys = true;
      trustedWithAgentForwarding = true;
      publicKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIYgeTANz3rdtM147P2u4JMHeoKapJS+KOnCbOxhbcqr"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDV3HiV7xEWURwT3wYy1mrqGFTe5JdTZoOt6Zhd+MEy+XPyk+ZCNINNItkyqJ0Nm4D9M0yRHei4X/yUdU3HdVJM2draa0gstyFUuxfUZMtrH5Nd27sQMcBwnzOaZTGnd9ODnc1mZ6w3kTeo/yAHDkiVhIcoLCqa/vK/8y1Zrr182ZLpEeXwF2u01CpiRdy/9QhxsCUphdBryYOIgIOPIWLcog2GFGECcCHA7JlI+sJoz4dsOh0t+3HJ6PfvVUaQ4uqzlTyZnyP3hGsqjxVRvBR0i8odk2WCT111zSk+sHjAYmF03A8tSBx58g+h4K2aAHHFsiL9kuMuaKHEUXw2aUGIQBlIL56T7Xx+4fLBSip1n41/3PpPxQMr6c44rYor69zQCWZePxH4vfUur5S78j3usE/JLBnuz1I9FkmLZwau4qIc+MYpiguz7AlX6jL5/WGx5RxLltLYDrJ066OJfqcgNm7in5xBCx2zWvhQ2X/lZ3CuTxs91ZBp9Teoless0BpfJ0XaWtearKyESlsQvIDjjD95+pbf8WG3kiSao5zRkHc6FbESqO83yeQyfNL2tjfdtu58xpHyX3J/2AXvd0vBtJyL8TyhJDFwzFrlqxaH0CzxEzxBlYeVf0iBanVZabi9QwHmrl0siJCCp7sNyiz/rYbyZ1A19XPQYfNLIje+yQ=="
      ];
    };
  };

  networking.hostName = "osprey";
  networking.domain = "michai.li";

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
