{pkgs, ...}: {
  programs = {
    steam = {
      enable = true;
      localNetworkGameTransfers.openFirewall = true;
    };
    obs-studio = {
      enable = true;
      enableVirtualCamera = true;
      plugins = builtins.attrValues {
        inherit
          (pkgs.obs-studio-plugins)
          obs-pipewire-audio-capture
          looking-glass-obs
          ;
      };
    };
  };
}
