{iliPresets, ...}: {
  mich.meta = {
    ssh = {
      knowNodesPublicKeys = true;
      trustedWithAgentForwarding = true;
      publicKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFzac3ClApFTfKj4/KK8DGgsQSt48n/S70KB8gROFAdD"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC29W9AooT0XwwHFSgjGEFEEO1PfOia1zxOqPHTGB3O/bzsHMRlO6cjPC10CipSuNZYgNyboPPGjmg3i3x2XjDvLNikJf2Jp61HiyNQcyPGSsn+h6/Bf/9xTsv6OybFyEP1Z2RYGQAMpM7iVcih7j0Tepxo8N8pXwbc8BJtuImbdg27xZ8w9HGbFycmFWvFgwZtoLwKk28J2AqeB7lLqgOoC+zzUDSsxkrhushfXQcshbiIDp7ui9xyqBJ43WPJFQaEcfAD1aW7h8cygbSnTvroE40wtWpzy5peWv3XYxu5DeXKVCBlsdmdWOuUWXDnvOPd51a0lgQaH4Hz27Tj4Dke0ECEmOx0uxyF1yHhtppyI01mgw1/wWctSl8YsLZ0xjVo9Af0gIK+J8EjDQFdlsE160AlZW0NusI46YQnnWnB84hu1rSpySYFV7Hw5UtTEEB/amFUs+6SaFxu9WCGcuLTD2KYhUs2L99Zt1yCFt3RELx6ZZQg4SYBW8Enkp061hge4ALfoUQ7E0QPVMwTjoT9MCV4imOvLqu75CN5R8BoSrHrsaGoXffGP/M6UTnhxVPJpkp8f8EfjuhhPU5tfs29FJgE8NMYahIiHMSIrBnysFPGx3V8JpQwbItRzv0C4t+n3NoJq9GUgaX3Xz7koAJ9WFcnDWtT/jFHBCxutkW1Uw=="
      ];
      extraConfig = {
        # The system doesn't expose SSH to the internet directly.
        ProxyJump = "raptor.michai.li";
      };
    };
  };

  networking.hostName = "sidewinder";
  networking.domain = "raptor.michai.li";
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

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

  system.stateVersion = "25.05";
}
