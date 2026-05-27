{iliPresets, ...}: {
  mich.hive = {
    ssh = {
      knowNodesPublicKeys = true;
      trustedWithAgentForwarding = false;
      publicKeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDeNOo4QuIN20DU9kyhTD//gadnVGgXAaF8MgByPQkjGZCzUhPsajqi62VsCTCM6BwEUUt13eU6PX2Zh6HPAudm1W6L8ztdCas73gpHIGNwaQoLUrPM4Kk+yLPwdBoz9HyPs7rydbjU99MLTlxhQMCLWyr74GdFJ65AF8t1nmzIYtMEPQHocgegE3wD5BLU9Dmuwhi4sx7YdCnm+1m4Gn6CiDXwXWtb1tJwmyfRGLjcPk2QNaoM2kEshPBA0+1QSsoNY/D7tf9dNyAVbB6sBrUj6OhHzt03gw+3HEGWp08NcTHGKWuFyHP7n8oKLK7hBlXS4KbGJV7KSyyIRMMuSDZhZ9Uo4hJPch6kt6naqV84khzjeo3FjE+h4oFpoFDqwHthFCVxKOGiRkkyuhwm2cbp3gEgFzos8RoqG5N5OVXFfA5Ks50ladW15YP0XhlsNvRmqbIhnMMYb0Okz2DCbI5BrlZe1MDnFFJZxib3Qy5g67Jn3FQ3ebcjwVOV17lkXIecE2+GR+fCB4Ub0TRb0ySYYyKRZnGI4ACg48StCoAHTLJjEdoxVLSC650oCusFfzPcBXroCOkMoeRumfTXErbM/tUkJ3nc2Fw/JkZREn7URDNbvsVBugLCTxRswCnGQ5lgv4SKwtK17CFWGyYlodK3iG9sLOw6x5W0WILS5cKKww=="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDXdbP1ImTvEqp60zjSvJeGUBJlYBS0RlRC0Pj6FAfRN"
      ];
    };
  };

  networking.hostName = "polaris";
  networking.domain = "michai.li";

  imports = builtins.attrValues {
    inherit
      (iliPresets.hive)
      base
      ;
    inherit
      (iliPresets)
      nix
      openssh
      comma
      ;
  };

  system.stateVersion = "26.05";
}
