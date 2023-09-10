# ZBOX with Proxmox

1. [Install](#install)
2. [PfSense Firewall](#pfsense)
3. [Pi Hole - DNS/DHCP](#pihole)
4. [Dagobert - OMV NAS](docs/dagobert.md)
5. [Autopirate - Media Management](docs/autopirate.md)
6. [Curator - ElasticSearch Monitoring](docs/curator.md)
7. [Dagobert - OMV NAS](docs/dagobert.md)
8. [Infra](docs/infra.md)

</br>

## Install

Follow node installations instructions from [minicluster](../minicluster/docs/Installation.md)
Note that minicluster ansible commands cover zbox, but not other commands like start and stop.

Configure backup, mount /volume1/nfs-zbox as nfs-jabba. NFS squash:Map all users to admin (on Synology). Else LXC containers will not be able to write to NFS share.


Configure Proxmox VE No-Subscription Repository, add
```deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription``` to /etc/apt/sources.list

NO - THIS INSTALLS TOO MUCH: Packages to install manually: ```apt install tasksel conky-all -y```.
Copy [conky.conf](files/conky.conf) to ```~/.config/conky/conky.conf```.

Setup and update with ```ansible-playbook ansible/setup.yml```


</br>

## PfSense

Download pfSsense Ise from [pfSense download page](https://www.pfsense.org/download/)
Upload ISO to proxmox local storage
Create VM
    General
        VM ID   5001
        Name    pfsense
        Options start at boot, order 100 delay 0, shotdown timeout 30
    OS
        pfsense iso
        Linux 6.x kernel
    System      Default, qemu agent comes later
    Disk
        Size    2 GB
        Cache   Write back
        Options Discard, IOThread, SSD emulation
    CPU         Cores   4
    Memory
        MiB     2048
        Min     2048
        Options Ballooning off
    Network     Default

Before starting, edit network devices
    Network device vmbr0
    USB Device vendor TP-Link USB 10/100/1000 LAN (2357:0601)

Note: TP-Link 300 was not working with Proxmox 8.0-2, but works with 7.4-16

High CPU by dbus-daemon? (from [proxmox forum](https://forum.proxmox.com/threads/udev-malfunction-udisksd-high-cpu-load.99169/)

```bash
systemctl mask udisks2.service
systemctl stop udisks2.service```

</br>

## PiHole

Install LXC debian image, then  <https://docs.pi-hole.net/main/basic-install/>

RAM 512 MB, CPU 2, Disk 2 GB, no privileges

```bash
apt install curl -y
curl -sSL https://install.pi-hole.net | bash
# set admin pwd
pihole -a -p
# update pihole
apt update && apt upgrade -y
pihole -up
````

When this is shown at login: ```bash: warning: setlocale: LC_ALL: cannot change locale (en_US.UTF-8)```
run ```sudo dpkg-reconfigure locales``` and select en_US.UTF-8

