{...}: {
  imports = [../printing.nix];
  mich.hive.defaultUser.extraGroups = ["scanner" "lp"];
}
