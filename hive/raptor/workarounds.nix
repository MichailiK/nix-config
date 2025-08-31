{
  pkgs,
  lib,
  ...
}: {
  /*
  disable NIC hardware offloading features as workaround for hanging ethernet device:
  ```
  kernel: e1000e 0000:00:1f.6 eno1: Detected Hardware Unit Hang:
    TDH                    <30>
    TDT                    <1a>
    next_to_use            <1a>
    next_to_clean          <2f>
    buffer_info[next_to_clean]:
      time_stamp           <100029224>
      next_to_watch        <30>
      jiffies              <10003db40>
      next_to_watch.status <0>
    MAC Status             <40080083>
    PHY Status             <796d>
    PHY 1000BASE-T Status  <3800>
    PHY Extended Status    <3000>
    PCI Status             <10>
  ```
  */
  systemd.services.ethtool-eno1 = {
    description = "ethtool-eno1";
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = "${lib.getExe pkgs.ethtool} gso off gro off tso off tx off rx off rxvlan off txvlan off";
    };
    wantedBy = ["multi-user.target"];
  };
}
