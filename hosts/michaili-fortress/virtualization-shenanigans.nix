{
  pkgs,
  config,
  ...
}:
{
  users.groups = {
    kvmfr = { };
  };
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = false;
      ovmf = {
        enable = true;
        packages = [
          (pkgs.OVMFFull.override {
            secureBoot = true;
            tpmSupport = true;
          }).fd
        ];
      };
      verbatimConfig = ''
        cgroup_device_acl = [
          "/dev/null", "/dev/full", "/dev/zero",
          "/dev/random", "/dev/urandom",
          "/dev/ptmx", "/dev/kvm",
          "/dev/kvmfr0"
        ]
      '';
    };
  };
  programs.virt-manager.enable = true;
  boot = {
    blacklistedKernelModules = [ "nouveau" ];
    extraModulePackages = [ config.boot.kernelPackages.kvmfr ];
    kernelParams = [
      "intel_iommu=on"
      "vfio.pci.ids=10de:2504,10de:228e,144d:a80a"
      "kvmfr.static_size_mb=32"
      "split_lock_detect=warn" # TODO: Figure out whether I even need to disdable split lock deteciton
    ];
    initrd.kernelModules = [
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"
      "kvmfr"
    ];
  };
  environment.etc = {
    "looking-glass-client.ini".text = ''
      [app]
      shmFile=/dev/kvmfr0
    '';
  };

  #"apparmor.d/local/abstractions/libvirt-qemu" =
  #  lib.mkIf config.security.apparmor.enable {
  #    text = lib.mkIf config.security.apparmor.enable apparmorAbstraction;
  #};

  services.udev.extraRules = ''
    SUBSYSTEM=="kvmfr", OWNER="qemu-libvirtd", GROUP="kvmfr", MODE="0660"
  '';

  environment.systemPackages = [ pkgs.looking-glass-client ];
}
