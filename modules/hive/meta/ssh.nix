{
  lib,
  config,
  options,
  nodes ? { },
  ...
}:
let
  inherit (lib) mkOption mkEnableOption types;
  cfg = config.mich.meta.ssh;
in
{
  options.mich.meta.ssh =
    let
      originalOpts = options.mich.ssh.hosts.type.getSubOptions [ ];
    in
    {
      inherit (originalOpts) hostName publicKeys;

      enable = mkOption {
        type = types.bool;
        default = config.services.openssh.enable;
        description = ''
          Whether to enable SSH meta options.
          By default this mirrors services.openssh.enable.
          Disabling this option will avoid adding this node to the known hosts
          of other nodes in the hive (with the knowNodesPublicKeys option enabled)
        '';
      };

      host = originalOpts.host // {
        description = originalOpts.host.description + ''

          Defaults to node's networking.hostName.
          If networking.domain is set, uses config.networking.fqdn as well.
        '';
        default =
          [
            config.networking.hostName
          ]
          ++ (lib.optionals (config.networking.domain != null) [
            config.networking.fqdn
          ]);
      };

      knowNodesPublicKeys = mkEnableOption ''
        When enabled, adds the public keys of all nodes in the hive as known hosts
        to this system.
      '';

      trustedWithAgentForwarding = mkEnableOption ''
        When enabled, all other nodes in the hive, with this option enabled,
        will SSH into this node with their SSH agents forwarded by default.
        This means that this node can do operations with the private SSH key.
      '';
    };

  config.assertions = [
    {
      assertion = cfg.enable || !cfg.knowNodesPublicKeys;
      message = "config.mich.meta.ssh.knowNodesPublicKeys cannot be enabled without enabling config.mich.meta.ssh.enable";
    }
    {
      assertion = cfg.enable || !cfg.knowNodesPublicKeys;
      message = "config.mich.meta.ssh.trustedWithAgentForwarding cannot be enabled without enabling config.mich.meta.ssh.enable";
    }
  ];

  config.mich.ssh.hosts = lib.mkIf cfg.enable (
    let
      # Only consider nodes with SSH enabled
      filteredNodes = lib.filterAttrs (name: node: node.config.mich.meta.ssh.enable == true) nodes;
    in
    (
      # Add the (host) names & public keys of all the nodes to this system's known hosts file.
      lib.optionalAttrs cfg.knowNodesPublicKeys (
        builtins.mapAttrs (name: node: {
          inherit (node.config.mich.meta.ssh) host hostName publicKeys;
        }) filteredNodes
      )
    )
    # When trustedWithAgentForwarding is enabled, set the `ForwardAgent` SSH
    # option to true for all the hosts/nodes that also have this option enabled.
    // (lib.optionalAttrs cfg.trustedWithAgentForwarding (
      let
        # Only consider nodes that also have trustedWithAgentForwarding enabled
        trustedNodes = lib.filterAttrs (
          name: node: node.config.mich.meta.ssh.trustedWithAgentForwarding == true
        ) filteredNodes;
      in
      builtins.mapAttrs (name: node: {
        inherit (node.config.mich.meta.ssh) host hostName;
        extraConfig = {
          ForwardAgent = true;
        };
      }) trustedNodes
    ))
  );

}
