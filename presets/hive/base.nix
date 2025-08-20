{...}: {
  imports = [../base.nix];
  mich.meta.defaultUser = {
    name = "michaili";
    description = "Michail K";
    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOct0GpSUGR8eFXiyPF6rHFQ9r97rdH/+rv/GDZnSyqS openpgp:0x5E718B7B"
    ];
  };
}
