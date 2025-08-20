{inputs, ...}: {
  imports = [
    inputs.nix-index-database.nixosModules.nix-index
  ];
  programs.nix-index-database.comma.enable = true;

  # Do not let comma cache paths because that bit me before
  # https://github.com/NixOS/nixpkgs/issues/431637#issuecomment-3162634892
  environment.sessionVariables.COMMA_CACHING = "1";
}
