{
  pkgs,
  lib,
  ...
}: {
  imports = [./base.nix];

  environment.systemPackages = builtins.attrValues {
    inherit (pkgs) alacritty fuzzel xwayland-satellite swaylock;
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
