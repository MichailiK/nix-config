{pkgs, ...}: {
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    # https://chrisdown.name/2026/03/24/zswap-vs-zram-when-to-use-what.html
    kernelParams = ["zswap.enabled=1" "zswap.shrinker_enabled=1"];

    # systemd initrd is nicer & faster than the legacy script-based one
    initrd.systemd.enable = true;
  };

  networking = {
    # systemd-networkd is preferred for configuring network interfaces
    useNetworkd = true;
    # logs are generally not needed & too noisy, especially on internet-exposed nodes
    firewall.logRefusedConnections = false;
    # used by traceroute to discover hops
    firewall.extraCommands = ''
      iptables -A INPUT -p udp --dport 33434:33534 -j REJECT --reject-with icmp-port-unreachable
      ip6tables -A INPUT -p udp --dport 33434:33534 -j REJECT --reject-with icmp6-port-unreachable
    '';
  };
  systemd.network.enable = true;

  # only users in the wheel group are expected to ever use sudo
  security.sudo.execWheelOnly = true;

  environment.systemPackages = builtins.attrValues {
    inherit
      (pkgs)
      # system monitor
      htop
      btop
      # hardware tools
      sdparm
      hdparm
      smartmontools
      pciutils
      usbutils
      nvme-cli
      # network tools
      fuse
      fuse3
      sshfs
      tcpdump
      # utils
      dig
      file
      jq
      ;
  };

  # ensure the userspace tools for some commonly used filesystems are present
  boot.supportedFilesystems = [
    "ext4"
    "btrfs"
    "ntfs"
    "vfat"
    "xfs"
  ];

  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
      configure = {
        packages.myVimPackages = with pkgs.vimPlugins; {
          start = [vim-wayland-clipboard];
        };
      };
    };
    git = {
      enable = true;
      lfs.enable = true;
    };
  };

  # Popular SSH servers
  mich.ssh.hosts = {
    # https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
    "github.com" = {
      publicKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl"
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk="
      ];
    };
    # https://docs.gitlab.com/user/gitlab_com/#ssh-host-keys-fingerprints
    "gitlab.com" = {
      publicKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf"
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFSMqzJeV9rUzU4kWitGjeR4PWSa29SPqJ1fVkhtj3Hw9xjLVXVYrU9QlYWrOLXBpQ6KWjbjTDTdDkoohFzgbEY="
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsj2bNKTBSpIYDEGk9KxsGh3mySTRgMtXL583qmBpzeQ+jqCMRgBqB98u3z++J1sKlXHWfM9dyhSevkMwSbhoR8XIq/U0tCNyokEi/ueaBMCvbcTHhO7FcwzY92WK4Yt0aGROY5qX2UKSeOvuP4D6TPqKF1onrSzH9bx9XUf2lEdWT/ia1NEKjunUqu1xOB/StKDHMoX4/OKyIzuS0q/T1zOATthvasJFoPrAjkohTyaDUz2LN5JoH839hViyEG82yB+MjcFV5MU3N1l1QL3cVUCh93xSaua1N85qivl+siMkPGbO5xR/En4iEY6K2XPASUEMaieWVNTRCtJ4S8H+9"
      ];
    };
  };
}
