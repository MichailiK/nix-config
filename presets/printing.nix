# Preset for dealing with printing & scanning of (mostly) IP-based printers
# That support the [IPP Everywhere](https://www.pwg.org/ipp/everywhere.html)
# protocol, which is pretty much every printer that advertises things like
# WiFi/LAN, AirPrint, Android/Mopria, IPP, ... printing.
#
# For scanners, make sure you add your user(s) to the scanner & lp groups.
{
  pkgs,
  lib,
  config,
  ...
}: {
  # Both CUPS and SANE rely on mDNS/DNS-SD for automatic IP printer discovery.
  # As of writing, both CUPS and SANE require Avahi to accomplish this
  # and do not support systemd-resolved.
  # - CUPS: https://github.com/OpenPrinting/libcups/issues/81
  # - sane-airscan has a hard dependency on avahi-client:
  #   https://github.com/alexpevzner/sane-airscan/blob/1d174de6858abb1950f2f296e5349e3bd32c56a7/meson.build#L47
  services.resolved.settings.Resolve.MulticastDNS = false;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  services.printing = {
    enable = true;
    # CUPS Drivers for discovering IPP Everywhere printers
    drivers = builtins.attrValues {
      inherit (pkgs) cups-filters cups-browsed;
    };
  };
  # For USB-connected printers that support IPP Everywhere
  services.ipp-usb.enable = true;

  # Used by KDE settings & GNOME control center for configuring printers via GUI
  # TODO perhaps dont enable this for non-GUI/non-Desktop systems?
  programs.system-config-printer.enable = true;

  # Scanning
  hardware.sane = {
    enable = true;
    extraBackends = [pkgs.sane-airscan];
    disabledDefaultBackends = ["escl"]; # sane-airscan is more maintained & already covers eSCL devices
  };
  services.udev.packages = [pkgs.sane-airscan];

  # Scanning frontends
  environment.systemPackages = lib.optionals config.services.desktopManager.plasma6.enable (builtins.attrValues {
    inherit (pkgs.kdePackages) skanlite skanpage;
  });
  # GNOME users should enable `services.gnome.core-apps.enable`
  # to get GNOME's simple-scan / Document Scanner package.
}
