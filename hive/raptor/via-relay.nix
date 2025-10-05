{ lib, pkgs, ... }:
{
  networking.firewall.allowedUDPPorts = [ 51820 ];
  networking.wireguard.interfaces.via-relay = {
    ips = [ "10.0.0.1/30" ];
    listenPort = 51820;
    privateKeyFile = "/etc/via-relay-experiment/private";
    postSetup = "${lib.getExe' pkgs.procps "sysctl"} -w net.ipv4.conf.via-relay.forwarding=1";
    peers = [
      {
        publicKey = "BKgFwP+HDHjMmVwJG8Gj2kdVxLoNSMlexnIxnY0mp0o=";
        allowedIPs = [
          "10.0.0.2/32"
          "78.46.83.227/32"
          "2a01:4f8:120:11e6:ffff:7669:6100:1/128"
        ];
      }
    ];
  };
}
