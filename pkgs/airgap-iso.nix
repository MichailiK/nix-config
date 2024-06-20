{
  nixpkgs,
  systempkgs,
}: let
  pkgs = systempkgs.extend (self: super: {
    linux_hardened_no_net = pkgs.linuxPackagesFor (pkgs.linux_hardened.override {
      #enableCommonConfig = false;
      structuredExtraConfig = let
        inherit (pkgs.lib) mkForce kernel;
        forceNo = mkForce kernel.no;
      in {
        # Disable module loading
        # Looks like disabling modules causes build failures, as some install phase script seems to break, causing failures.
        # MODULES = forceNo;

        # Disable Network devices & every other config option that automatically flips on NETDEVICES & ETHERNET
        ETHERNET = forceNo;
        NETDEVICES = forceNo;
        ATM_DRIVERS = forceNo;
        CRYPTO_DEV_FSL_DPAA2_CAAM = forceNo;
        MANA_INFINIBAND = forceNo;
        MLX4_INFINIBAND = forceNo;
        MLX5_INFINIBAND = forceNo;
        INFINIBAND_OCRDMA = forceNo;
        INFINIBAND_USNIC = forceNo;
        INFINIBAND_VMWARE_PVRDMA = forceNo;
        INFINIBAND_IPOIB = forceNo;
        ISDN = forceNo;
        ARCNET = forceNo;
        MLX4_EN = forceNo;
        MLX5_CORE_EN = forceNo;
        MLX5_DPLL = forceNo;
        IEEE802154_DRIVERS = forceNo;
        PHYLINK = forceNo;
        PHYLIB = forceNo;
        LCS = forceNo;
        CTCM = forceNo;
        NETIUCV = forceNo;
        QETH = forceNo;
        SCSI_BNX2X_FCOE = forceNo;
        SCSI_BNX2_ISCSI = forceNo;
        SCSI_CXGB3_ISCSI = forceNo;
        IPWIRELESS = forceNo;
        NET_DSA = forceNo;

        # Disable WLAN/802.11 configuration API
        CFG80211 = forceNo;

        # Disable Sound... in my case I don't need sound
        SOUND = forceNo;

        # Disable some of the graphics drivers as they take a while to compile
        DRM_RADEON = forceNo;
        DRM_AMDGPU = forceNo;
        DRM_NOUVEAU = forceNo;
        DRM_I915 = forceNo;
      };
      ignoreConfigErrors = true;
    });
  });
  lib = pkgs.lib;
in
  (nixpkgs.lib.nixosSystem {
    system = pkgs.system;
    modules = [
      "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
      ({options, ...}: {
        boot.kernelPackages = lib.mkForce pkgs.linux_hardened_no_net;
        # Remove the virtio_net kernel module, it gets shipped by default but causes breakage in this configuration.
        boot.initrd.availableKernelModules = lib.mkForce (lib.filter (module: module != "virtio_net") options.boot.initrd.availableKernelModules.default);
      })
      {
        networking.useDHCP = false;
        networking.interfaces = {};
        networking.hostName = "nixos-airgap";
        environment.systemPackages = [pkgs.gnupg];
        isoImage.squashfsCompression = "zstd -Xcompression-level 6";
      }
    ];
  })
  .config
  .system
  .build
  .isoImage

