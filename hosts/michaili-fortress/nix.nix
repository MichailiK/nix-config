{
  lib,
  inputs,
  pkgs,
  config,
  ...
}:
# Stolen from https://github.com/itslychee/config/blob/0719e197b511a389264127dedeb87a2985bea486/modules/nix/settings.nix#L8-L17
let
  inherit (lib) mapAttrs' mapAttrsToList filterAttrs;
  inputFarm = pkgs.linkFarm "input-farm" (
    mapAttrsToList (name: path: {
      inherit
        name
        path
        ;
    }) (filterAttrs (name: _value: name != "self") inputs)
  );
in {
  environment.sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";
  nixpkgs.config.allowUnfree = true;

  nix = {
    registry =
      mapAttrs' (name: val: {
        inherit name;
        value.flake = val;
      })
      inputs;

    nixPath = [inputFarm.outPath];
    channel.enable = false;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      nix-path = config.nix.nixPath;
      flake-registry = "";
    };
  };
}
