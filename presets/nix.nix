# Preset for adjusting Nix configuration. Includes enabling flakes, using
# this flake's inputs as the flake registry & nix path, and allowing unfree software.
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
    package = pkgs.lix;
    registry =
      mapAttrs' (name: val: {
        inherit name;
        value.flake = val;
      })
      inputs;

    nixPath = [inputFarm.outPath];
    channel.enable = false;
    settings = {
      trusted-users = [
        "@wheel"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      nix-path = config.nix.nixPath;
      flake-registry = "";
    };
  };

  # thank u lychee for thanking raf https://github.com/itslychee/config/blob/0719e197b511a389264127dedeb87a2985bea486/modules/nix/settings.nix#L59-L63
  systemd.tmpfiles.rules = lib.mkIf (!config.nix.channel.enable) [
    "R /root/.nix-defexpr/channels - - - -"
    "R /nix/var/nix/profiles/per-user/root/channels - - - -"
  ];
}
