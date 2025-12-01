{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = builtins.attrValues {
    inherit
      (pkgs)
      qpwgraph
      #easyeffects
      carla
      # VST plugins
      lsp-plugins
      vital
      infamousPlugins
      ;
  };
  # From https://discourse.nixos.org/t/lmms-vst-plugins/42985/3
  environment.variables = let
    makePluginPath = format:
      (lib.makeSearchPath format [
        "$HOME/.nix-profile/lib"
        "/run/current-system/sw/lib"
        "/etc/profiles/per-user/$USER/lib"
      ])
      + ":$HOME/.${format}";
  in {
    DSSI_PATH = makePluginPath "dssi";
    LADSPA_PATH = makePluginPath "ladspa";
    LV2_PATH = makePluginPath "lv2";
    LXVST_PATH = makePluginPath "lxvst";
    VST_PATH = makePluginPath "vst";
    VST3_PATH = makePluginPath "vst3";
  };
}
