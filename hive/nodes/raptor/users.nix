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
