{pkgs, ...}: {
  virtualisation.libvirtd = {
    enable = true;
    extraConfig = "access_drivers = [ \"polkit\" ]";

    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
    onBoot = "start";
    onShutdown = "shutdown";
  };

  security.polkit = {
    enable = true;
    #debug = true;
    extraConfig = ''
      const VIRTD_ALLOWED_GLOBAL_ACTIONS = [
        "org.libvirt.unix.manage", // Access to the libvirtd unix socket
        "org.libvirt.api.connect.getattr", // Access to connection APIs
        "org.libvirt.api.connect.read", // Read host

        "org.libvirt.api.connect.search-domains", // Request a list of domains (but is filtered by the domain.getattr action)

        "org.libvirt.api.connect.search-networks", // Request a list of networks
        "org.libvirt.api.network.read", // List networks
        "org.libvirt.api.network.getattr", // Read networks

        "org.libvirt.api.connect.search-storage-pools", // Request a list of storage pools
        "org.libvirt.api.storage-pool.getattr", // List storage pools
        "org.libvirt.api.storage-pool.read", // Read storage pools
        "org.libvirt.api.storage-pool.refresh", // Refresh storage pools
        "org.libvirt.api.storage-pool.search-storage-vols", // List storage pool volumes

        "org.libvirt.api.storage-vol.getattr", // List storage volume
        "org.libvirt.api.storage-vol.read", // Read storage volume

        "org.libvirt.api.connect.search-node-devices", // Request a list of node devices (virtual & physical hardware)
        "org.libvirt.api.node-device.getattr", // List node devices (virtual & physical hardware)
        "org.libvirt.api.node-device.read", // Read node devices (virtual & physical hardware)
      ];

      // Actions allowed when the user is associated with a domain/vm (the domain name starts with the username & is followed by a dash)
      const VIRTD_ALLOWED_DOMAIN_ACTIONS = [
        "org.libvirt.api.domain.getattr", // Access to domain APIs
        "org.libvirt.api.domain.read",  // Read domain/VM
        "org.libvirt.api.domain.read-secure", // Read secure domain (not sure what that means but virt-manager needs it)
        "org.libvirt.api.domain.list",  // List domains/VMs (but is filtered by domain.getattr action)
        "org.libvirt.api.domain.start", // Start domain/VM
        "org.libvirt.api.domain.stop", // Stop domain/VM
        "org.libvirt.api.domain.init-control", // Init control domain/VM (reboot/shutdown)
        "org.libvirt.api.domain.pm-control", // Power management control (request guest to sleep/hibernate)
        "org.libvirt.api.domain.hibernate", // Hibernate domain/VM
        "org.libvirt.api.domain.reset", // Reset domain/VM
        "org.libvirt.api.domain.screenshot", // Take domain/VM screenshot
        "org.libvirt.api.domain.send-input", // Send (keyboard) input to domain/VM
        "org.libvirt.api.domain.send-signal", // Send (UNIX) signal to domain/VM
        "org.libvirt.api.domain.open-device", // Open device (e.g. serial device)
      ];

      function virtdTest(action, subject) {
        //if (action.id.indexOf("org.libvirt") !== 0) return polkit.Result.NOT_HANDLED;
        //if (!subject.isInGroup("vm-users")) return polkit.Result.NOT_HANDLED;

        // Allow management access to libvirt
        if (VIRTD_ALLOWED_GLOBAL_ACTIONS.indexOf(action.id) !== -1)
          return polkit.Result.YES;

        // The actions below are only allowed with domains prefixed by their own name
        const domainName = action.lookup("domain_name");

        // The domain name can be undefined
        if (domainName == null) return polkit.Result.NO;
        if (domainName.indexOf(subject.user + "-") !== 0) return polkit.Result.NO;

        if (VIRTD_ALLOWED_DOMAIN_ACTIONS.indexOf(action.id) !== -1)
          return polkit.Result.YES;

        return polkit.Result.NOT_HANDLED;
      }

      polkit.addRule(function(action, subject) {
        // Don't handle non-libvirt actions
        if (action.id.indexOf("org.libvirt") !== 0)
          return polkit.Result.NOT_HANDLED;

        // Implicitly allow all libvirt operations for wheel users
        if (subject.isInGroup("wheel"))
          return polkit.Result.YES;

        // Don't handle actions from users that arent in the vm-users group
        if (!subject.isInGroup("vm-users"))
          return polkit.Result.NOT_HANDLED;


        const domainName = action.lookup("domain_name");
        var domainText = "";
        if (domainName) domainText = " domain " + domainName;
        const result = virtdTest(action, subject);

        polkit.log("LIBVIRTD RULE: " + String(result) + " to " + subject.user + " using " + action.id + domainText);
        return result;
      });
    '';
  };
  environment.variables = {
    LIBVIRT_DEFAULT_URI = "qemu:///system";
  };
}
