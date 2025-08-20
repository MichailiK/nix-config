{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
  hostsOpts = {
    config,
    name,
    ...
  }: {
    options = {
      host = mkOption {
        type = types.nonEmptyListOf (types.strMatching "[^[:space:]]+"); # Non-empty non-whitespace characters
        description = ''
          The host pattern(s) that should be used to identify this system.
          Equivalent to ssh_config(5) Host keyword.
          Defaults to the attribute name.
        '';
        default = [name];
        example = [
          "example"
          "example.com"
          "example.tail1234.ts.net"
        ];
      };
      hostName = mkOption {
        type = types.nullOr (types.listOf (types.strMatching "[^[:space:]]+")); # Non-empty non-whitespace characters
        description = ''
          Specifies the real host name to log into.
          Equivalent to ssh_config(5) Hostname option.
          Generally, you should not set this option, unless there is only
          one hostname you would want to connect to this system through.
        '';
        default = null;
      };
      publicKeys = mkOption {
        type = types.listOf types.str;
        description = ''
          The expected SSH public keys for this host.
          Use `ssh-keyscan` to obtain the public keys of a server.
          Remove the host name from the output of `ssh-keyscan`.
        '';
        default = [];
        example = [
          "ssh-ed25519 AAAAC3Nza...22Ir8R"
          "ssh-rsa AAAAB3Nza...fzeRw=="
        ];
      };
      extraConfig = mkOption {
        type = types.attrsOf (
          types.oneOf [
            types.str
            types.bool
          ]
        );
        description = ''
          Extra configuration text prepended to `ssh_config` of this host.
          See ssh_config(5) manpage for options.
        '';
        default = {};
        example = ''
          {
            IdentityFile = "%d/.ssh/example_id_rsa";
            ForwardAgent = true; # translates to "yes"
            PasswordAuthentication = false; # translates to "no"
          }
        '';
      };
    };
  };
in {
  options.mich.ssh = {
    hosts = mkOption {
      default = {};
      type = types.attrsOf (types.submodule hostsOpts);
    };
  };

  config.programs.ssh.knownHostsFiles = let
    # Only consider hosts that have at least 1 public key specified
    hostsWithKeys =
      lib.filterAttrs (
        name: value: ((builtins.length value.publicKeys) > 0)
      )
      config.mich.ssh.hosts;
  in
    lib.optionals ((builtins.length (builtins.attrNames hostsWithKeys)) > 0) [
      (pkgs.writeText "mich_ssh_known_hosts" (
        ''
          # Automatically generated ssh_known_hosts file using mich.ssh.hosts.<name>

        ''
        + lib.concatMapAttrsStringSep "\n\n" (
          name: host: let
            # Host name of a node, formatted for ssh_known_hosts
            hostName =
              if (host.hostName != null)
              then host.hostName
              else builtins.concatStringsSep "," host.host;
            # ssh_known_hosts formatted presentation of a node's public keys.
            entries = builtins.concatStringsSep "\n" (builtins.map (key: "${hostName} ${key}") host.publicKeys);
          in ''
            # ${name}
            ${entries}
          ''
        )
        hostsWithKeys
      )).outPath
    ];

  config.programs.ssh.extraConfig = let
    # Only consider hosts that have some option that must be written to ssh_config
    hostsWithOptions =
      lib.filterAttrs (
        name: value:
          (value.hostName != null) || (builtins.length (builtins.attrNames value.extraConfig)) > 0
      )
      config.mich.ssh.hosts;
  in
    lib.optionalString (builtins.length (builtins.attrNames hostsWithOptions) > 0) (
      let
        configFile = pkgs.writeText "mich_ssh_config" (
          ''
            # Automatically generated ssh_config file using mich.ssh.hosts.<name>

          ''
          + lib.concatMapAttrsStringSep "\n\n" (
            name: host: let
              # Pattern to use in the Host keyword
              hostPattern = builtins.concatStringsSep " " (
                host.host
                ++ (
                  if (host.hostName != null)
                  then [host.hostName]
                  else []
                )
              );
              # extraConfig attrset formatted into a (tab-indented) string
              extraConfigFormatted =
                lib.concatMapAttrsStringSep "\n" (
                  name: value: "\t${name} ${
                    if value == true
                    then "yes"
                    else if value == false
                    then "no"
                    else value
                  }"
                )
                host.extraConfig;
            in
              "# ${name}\n"
              + "Host ${hostPattern}\n"
              + (
                if (host.hostName != null)
                then "\tHostname ${host.hostName}\n"
                else ""
              )
              + extraConfigFormatted
          )
          hostsWithOptions
        );
      in "Include ${configFile}"
    );
}
