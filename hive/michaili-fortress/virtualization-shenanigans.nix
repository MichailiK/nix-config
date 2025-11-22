{
  pkgs,
  config,
  ...
}: {
  programs.virt-manager.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = false;
      verbatimConfig = ''
        cgroup_device_acl = [
          "/dev/null", "/dev/full", "/dev/zero",
          "/dev/random", "/dev/urandom",
          "/dev/ptmx", "/dev/kvm",
          "/dev/kvmfr0"
        ]
      '';
    };
    onBoot = "ignore";
    onShutdown = "shutdown";
  };

  boot = {
    initrd = {
      # The NVMe module gets to bind to the SSD in initrd. vfio must be loaded
      # in initrd so it can bind to the SSD first.
      kernelModules = [
        "vfio"
        "vfio_pci"
        "vfio_iommu_type1"
      ];
    };
    kernelModules = [
      "kvmfr"
    ];
    extraModulePackages = [config.boot.kernelPackages.kvmfr];
    extraModprobeConfig = let
      pciIds = [
        "10de:2504" # NVIDIA GA106 [GeForce RTX 3060 Lite Hash Rate]
        "10de:228e" # NVIDIA GA106 High Definition Audio Controller
        "144d:a80a" # Samsung NVMe SSD Controller 980PRO
      ];
    in ''
      options kvmfr static_size_mb=32
      options vfio-pci ids=${builtins.concatStringsSep "," pciIds}
    '';
    kernelParams = [
      "intel_iommu=on"
      "split_lock_detect=warn" # TODO: Figure out whether I even need to disdable split lock deteciton
    ];
  };

  users.groups = {
    kvmfr = {};
  };

  environment.systemPackages = [pkgs.looking-glass-client];

  environment.etc = {
    "looking-glass-client.ini".text = ''
      [app]
      shmFile=/dev/kvmfr0
    '';
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="kvmfr", OWNER="qemu-libvirtd", GROUP="kvmfr", MODE="0660"
  '';
}
