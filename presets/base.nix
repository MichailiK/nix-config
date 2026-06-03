{
  lib,
  pkgs,
  ...
}: {
  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

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

  services.resolved = {
    enable = true;
    settings.Resolve = {
      # DNS servers should be first ordered by IPv6/IPv4, then primary/secondary,
      # then by preference.
      DNS = lib.join " " [
        # IPv6 primaries
        "2606:4700:4700::1111#cloudflare-dns.com"
        "2001:4860:4860::8888#dns.google"
        "2620:fe::fe#dns.quad9.net"
        # IPv6 secondaries
        "2606:4700:4700::1001#cloudflare-dns.com"
        "2001:4860:4860::8844#dns.google"
        "2620:fe::9#dns.quad9.net"
        # IPv4 primaries
        "1.1.1.1#cloudflare-dns.com"
        "8.8.8.8#dns.google"
        "9.9.9.9#dns.quad9.net"
        # IPv4 secondaries
        "1.0.0.1#cloudflare-dns.com"
        "8.8.4.4#dns.google"
        "149.112.112.112#dns.quad9.net"
      ];
      FallbackDNS = ""; # Don't use any of the DNS servers built-in to systemd-resolved
      Domains = "~.";
      DNSOverTLS = true;
      DNSSEC = true;

      MulticastDNS = "resolve"; # Avahi is preferred for mDNS purposes esp. due to CUPS
    };
  };

  # Search domains & local DNS servers are not able to
  networking.networkmanager.connectionConfig = {
    "connection.dns-over-tls" = 1; # opportunistic
    # Off because fritz.box DNS servers claim to support DNSSEC but fail to provide
    # the appropriate DNSSEC records for their own search domain
    "connection.dnssec" = 0;
  };
  # TODO the above should be done for systemd-networkd managed interfaces too

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
