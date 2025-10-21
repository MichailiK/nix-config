{ ... }:
{
  mich.meta.defaultUser.extraGroups = [ "libvirtd" ];

  security.sudo.wheelNeedsPassword = false;
  security.sudo.execWheelOnly = true;

  boot = {
    swraid.enable = true;
    loader = {
      efi.canTouchEfiVariables = false;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        efiInstallAsRemovable = true;
      };
    };
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  networking.firewall.logRefusedConnections = false;
  networking.firewall.extraCommands = ''
    iptables -A INPUT -p udp --dport 33434:33534 -j REJECT --reject-with icmp-port-unreachable
    ip6tables -A INPUT -p udp --dport 33434:33534 -j REJECT --reject-with icmp6-port-unreachable
  '';

  systemd.services.sshd = {
    serviceConfig.LogFilterPatterns = [
      "Invalid user [^\s]+ from [^\s]+ port [0-9]+$"
      "Disconnected from invalid user [^\s]+ \[preauth\]$"
      "Connection closed by invalid user [^\s]+ \[preauth\]$"
    ];
  };
  systemd.services.sshd-session.serviceConfig.LogFilterPatterns = [
    "Invalid user [^\s]+ from [^\s]+ port [0-9]+$"
  ];

  networking = {
    useDHCP = false;
    usePredictableInterfaceNames = true;
  };

  fileSystems = {
    "/" = {
      device = "/dev/lvm-data/root";
      fsType = "btrfs";
      options = [
        "compress=zstd:3"
        "discard=async"
        "ssd"
      ];
    };
    "/boot" = {
      device = "/dev/md/raptor:boot";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
    "/nix" = {
      device = "/dev/lvm-data/nix";
      fsType = "btrfs";
      options = [
        "compress=zstd:5"
        "discard=async"
        "ssd"
      ];
    };
    "/home" = {
      device = "/dev/lvm-data/home";
      fsType = "btrfs";
      options = [
        "compress=zstd:3"
        "discard=async"
        "ssd"
      ];
    };
    "/var" = {
      device = "/dev/lvm-data/var";
      fsType = "btrfs";
      options = [
        "compress=zstd:5"
        "discard=async"
        "ssd"
      ];
    };
  };

  systemd.network = {
    enable = true;
    networks = {
      "internet" = {
        matchConfig = {
          MACAddress = "50:eb:f6:2f:36:10"; # eno1 NIC in Raptor
        };
        dns = [
          "2606:4700:4700::1111" # Cloudflare IPv6 primary
          "2606:4700:4700::1001" # Cloudflare IPv6 secondary
          "1.1.1.1" # Cloudflare IPv4 primary
          "1.0.0.1" # Cloudflare IPv4 secondary
        ];
        addresses = [
          { Address = "78.46.83.238/27"; } # raptor.michai.li
          { Address = "188.40.162.193/29"; } # gateway.raptor.michai.li
          { Address = "2a01:4f8:120:11e6::1/128"; } # raptor.michai.li
          { Address = "2a01:4f8:120:11e6:f000::1/80"; } # gateway.raptor.michai.li
        ];
        routes = [
          {
            Gateway = "78.46.83.225"; # Hetzner's Gateway
            # For new packets/connections that raptor sends
            # (such as ICMP TTL exceeded messages, generic traffic, ...)
            # We want to send them from its gateway IP.
            PreferredSource = "188.40.162.193"; # gateway.raptor.michai.li
          }
          {
            Gateway = "fe80::1"; # Hetzner's Gateway
            PreferredSource = "2a01:4f8:120:11e6:f000::1"; # gateway.raptor.michai.li
          }
        ];
        networkConfig = {
          # Since a routed/L3 networking setup is used for the virtual machines
          # in Raptor, Raptor must act as a router, by both forwarding IP packets
          # and responding to ARP/NDP requests on behalf of the VMs & Hetzner's gateway.
          IPv4Forwarding = true;
          IPv6Forwarding = true;
          IPv4ProxyARP = true;
          IPv6ProxyNDP = true;
        };
        cakeConfig = {
          Bandwidth = "1G";
          FlowIsolationMode = "dual-src-host"; # fairness is applied over source IPs (host, VMs, ...) first, then flows within them.
        };
      };
    };
  };
}
