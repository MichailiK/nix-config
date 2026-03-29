{
  pkgs,
  lib,
  ...
}: {
  # https://github.com/NixOS/nixpkgs/issues/247608
  systemd.network.wait-online.enable = lib.mkForce false;
  networking.networkmanager.enable = true;
  networking.useNetworkd = true;

  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    wireplumber.enable = true;
    pulse.enable = true;
  };
  fonts = {
    packages = builtins.attrValues {
      inherit
        (pkgs)
        noto-fonts-cjk-sans # no good CJK font seems to be bundled by default
        noto-fonts-cjk-serif
        inter
        roboto
        jetbrains-mono
        ;
    };
    fontconfig = {
      # KDE creates ~/.config/fontconfig/fonts.conf every time a user navigates
      # to System Settings -> Text & Fonts. It breaks emojis on Firefox.
      includeUserConf = false;

      defaultFonts = {
        sansSerif = [
          "Inter"
          "Noto Sans"
        ];
        serif = ["Noto Serif"];
        emoji = ["Noto Color Emoji"];
        monospace = [
          "JetBrains Mono"
          "Noto Sans Mono CJK SC" # CJK fallback
        ];
      };
    };
  };

  programs.kdeconnect.enable = true;
  programs.firefox = {
    enable = true;
    package = pkgs.librewolf;
  };

  programs.direnv.enable = true;

  environment = {
    # Make Chromium & Electron applications use Wayland
    sessionVariables.NIXOS_OZONE_WL = "1";

    systemPackages = builtins.attrValues {
      inherit
        (pkgs)
        vlc
        equibop
        handbrake
        vscodium
        zed-editor
        ;
    };
  };
}
