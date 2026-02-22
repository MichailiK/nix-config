{...}: {
  imports = [../printing.nix];
  mich.meta.defaultUser.extraGroups = ["scanner" "lp"];
}
