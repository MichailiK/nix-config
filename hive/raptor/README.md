# raptor

## Provisioning a new machine

Create a new libvirt domain:
- With the name of {user}-{domain_name}
- Using UEFI Firmware
- With pinned CPUs, e.g.:
  ```xml
  <vcpu placement="static">4</vcpu>
  <cputune>
    <vcpupin vcpu="0" cpuset="4"/>
    <vcpupin vcpu="1" cpuset="5"/>
    <vcpupin vcpu="2" cpuset="6"/>
    <vcpupin vcpu="3" cpuset="7"/>
    <emulatorpin cpuset="6,7"/>
  </cputune>
  ```
- Do not use the included Display & Video devices. There seems to be a bug
  in the QXL video drivers which, after running a VM for several weeks,
  may cause the kernel to deadlock when it tries to write to the console/framebuffer.
  VGA devices may work more stable, but that is untested. Instead, either use a
  VirtIO console (recommended) or a Serial console, as those allows more
  convenient troubleshooting & accessing a console on the guest using
  `virsh console {user}-{domain_name}`.
  - Ensure the guest OS is configured to use the console, e.g. kernel parameter
    `console=ttyS0` for a serial console or `console=hvc0` for VirtIO consoles.
  - On most Linux distros, the VirtIO Console is a module that needs to be loaded
    manually.

### Provisioning Storage

Create a new LVM volume for the VM by running
`lvcreate -L {size} -n guest-{user}-{domain_name} lvm-data`.
Add `/dev/lvm-data/guest-{user}-{domain_name}` as a disk to the domain.

When unprovisioning the VM, zero out the LVM volume first:
`sudo dd if=/dev/zero of=/dev/lvm-data/guest-{user}-{domain_name} bs=4M status=progress`
Then remove the volume with
`lvremove /dev/lvm-data/guest-{user}-{domain_name}`.

### Provisioning Network

Currently only up to 5 VMs can be easily configured with networking, via the
`br-vm1` to `br-vm5` bridges.

Pick an unused bridge and add a network interface to the domain. The MAC address
should be `52:54:00:00:00:0X`, where `X` is the number of the bridge, e.g.
`52:54:00:00:00:01` for `br-vm1`. If this is not done, the host's DHCP server
will fail to automatically configure IP for the guest.

rDNS entries should be updated to have a useful name, like
`{user}-{domain_name}.raptor.michai.li`, and A/AAAA records should be
added/updated appropiately.


## Users

Optionally, create a user on the host with the same name as the domain with a
public key for SSH access. Add them to the `vm-users` group.

Polkit restricts users in the `vm-users` group to only see & interact with
domains starting with `{user}-` (they cannot modify the domain.)
Users in the `libvirt` or `wheel` group can see, interact & modify all domains.
