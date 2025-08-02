{ rootPath, ... }:
{
  imports =
    let
      templates = names: (builtins.map (name: rootPath + /templates/${name}.nix) names);
    in
    templates [
      "hive/base"
      "hive/yubikey"
      "flakes"
      "desktop"
      "short-wireless"
    ];

  mich.meta = {
    ssh = {
      knowNodesPublicKeys = true;
      trustedWithAgentForwarding = true;
      publicKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMG2QkFvXuCT1WH17D3lTAEf5w0EGb3W9JKbA122Ir8R"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCimyHRgPmQGjw3m1kzsYJXg6w7eF2SLeaL5G2GBhAZoou4AVJAy/yXLpo4Jgd51cnMqSHsUMeKgM+cDfh3ytIQ8ogsiVDeHzBDt3fJ6Vftv58G8PFrhFaakOzkCfHl1bVfQE3PRZsRt1zNI9PJu5lZtnpnbo2rf5K0JR3LvKp1PmBUc6ttQ4Mvda55km3g3ZqWhyASbm2xg9zQC3xzr1QJ5Qulxmhk6VzYbT971OvdFG/pRU6pvY8P8auRdjr8lzzwFylv6Xs3H0OaszK3syEKeidFqeQRspuXipUdBjdx8EWJLskiexiutXBCGZ66+A6S56k1BGkvTFkMY6rAK/ra+9FvOGiLkB+GBDIjSJJzwmYm6YBkG1GBC3D0pTheLIGVngsjRcElcJis93XIjpS8plohdNv+AzTCleohPV1rGLppBemjWuwcbv8LM6gMAVucXluVSOZxNYnBwRxpep4uqR8qwwnbR+ktroSdPxMfQHoDQbq0ouAJBlm0a9YhdRjqLxt8m9x5O5Z+sLWVX90wV0XO/igDAg5owtXzS6YeLXaCKAqN3ROHOg6KKM94HlFqv1nt5746y5IdD64/A8JvjvL/nfXpf+EUtmixWuesa1lxK51rY3084re8Sx6KcpoBDRNlqkxMSDTQzeenhHrHx9Fv7vq972pexSClZfzeRw=="
      ];
    };
  };

  networking.hostName = "michaili-fortress";
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";

  system.stateVersion = "23.11";
}
