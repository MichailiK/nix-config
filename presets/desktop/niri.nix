# Very incomplete niri configuration
{
  pkgs,
  lib,
  ...
}: {
  imports = [./base.nix];

  environment.systemPackages = builtins.attrValues {
    inherit (pkgs) alacritty fuzzel xwayland-satellite swaylock;
    inherit (pkgs.kdePackages) konsole;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${lib.getExe pkgs.tuigreet} --time";
        user = "greeter";
      };
    };
  };
  programs.niri = {
    enable = true;
    useNautilus = true;
  };
}
