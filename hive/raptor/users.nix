{
  users = {
    mutableUsers = false;
    users = {
      test = {
        isNormalUser = true;
        extraGroups = ["vm-users"];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOct0GpSUGR8eFXiyPF6rHFQ9r97rdH/+rv/GDZnSyqS openpgp:0x5E718B7B"
        ];
      };
      lychee = {
        isNormalUser = true;
        extraGroups = ["vm-users"];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILv8G52B8ANAEczyOLd6N15pmasoVde1I9pXajQOeUL5 openpgp:0xF2E43235"
        ];
      };
      marshmallow = {
        isNormalUser = true;
        extraGroups = ["vm-users"];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICpSjyumudaVID5jTxLvYTSs9AimCWbRkicJVPZV+5GL hydra@media"
        ];
      };
    };
    groups = {
      vm-users = {};
    };
  };
}
