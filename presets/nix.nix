# Preset for adjusting Nix configuration. Includes enabling flakes, using
# this flake's inputs as the flake registry & nix path, and allowing unfree software.
{
  lib,
  inputs,
  pkgs,
  config,
  ...
}: let
  # hacky way to figure out which nixpkgs flake is being used in this system
  currentNixpkgsFlake =
    lib.findFirst
    (flake: flake.outPath == builtins.toString pkgs.path)
    null
    (builtins.attrValues inputs);
in {
  environment.sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";
  nixpkgs.config.allowUnfree = true;

  warnings =
    if (currentNixpkgsFlake == null)
    then [
      ''
        Could not figure which nixpkgs flake input is being used in this system.
        This will make `nix (run|shell|build) nixpkgs#...` invocations significantly slower!
      ''
    ]
    else [];

  nixpkgs.overlays = [
    (final: prev: {
      inherit
        (prev.lixPackageSets.stable)
        nixpkgs-review
        nix-eval-jobs
        nix-fast-build
        colmena
        ;
      comma = prev.comma.override {nix = prev.lix;};
    })
  ];

  nix = {
    package = pkgs.lix;
    channel.enable = false;
    settings = {
      trusted-users = [
        "@wheel"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operator"
      ];
      nix-path = config.nix.nixPath;
      flake-registry = "";
    };

    # Flake registry & Nix paths
    registry =
      (builtins.mapAttrs (name: val: {flake = val;})
        inputs)
      // {
        nixpkgs = lib.mkForce (
          if (currentNixpkgsFlake == null)
          then {
            to = {
              type = "path";
              path = builtins.toString pkgs.path;
            };
          }
          else {
            flake = currentNixpkgsFlake;
          }
        );
      };

    nixPath = let
      inputFarm = pkgs.linkFarm "input-farm" (
        lib.mapAttrsToList
        (name: path: {
          inherit
            name
            path
            ;
        })
        (
          lib.filterAttrs (name: _value: name != "self") (
            inputs
            // {
              nixpkgs =
                if (currentNixpkgsFlake != null)
                then currentNixpkgsFlake
                else {outPath = pkgs.path;};
            }
          )
        )
      );
    in [inputFarm.outPath];
  };

  systemd.tmpfiles.rules = lib.mkIf (!config.nix.channel.enable) [
    "R /root/.nix-defexpr/channels - - - -"
    "R /nix/var/nix/profiles/per-user/root/channels - - - -"
  ];
}
