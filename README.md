# ZBOX with Proxmox

1. [Install](#install)
2. [PfSense Firewall](#pfsense)
3. [Pi Hole - DNS/DHCP](#pihole)
4. [Dagobert - OMV NAS](docs/dagobert.md)
5. [Autopirate - Media Management](docs/autopirate.md)
6. [Curator - ElasticSearch Monitoring](docs/curator.md)
7. [Dagobert - OMV NAS](docs/dagobert.md)
8. [Infra - Infrastructure Containers](docs/infra.md)
9. [MacMini Ubuntu Desktop](#MacMini)
10. [Home Assistant](#home-assistant)


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
systemctl stop udisks2.service
```

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
```

When this is shown at login: ```bash: warning: setlocale: LC_ALL: cannot change locale (en_US.UTF-8)```
run ```sudo dpkg-reconfigure locales``` and select en_US.UTF-8

## MacMini Ubuntu Desktop

Enable wakeup from suspend on keyboard press (from <https://forums.linuxmint.com/viewtopic.php?p=1524543&sid=26cfac1903429672a3594c6de9a8500e#p1524543>)

```bash
# find RAPOO usb id
lsusb -t
/:  Bus 04.Port 1: Dev 1, Class=root_hub, Driver=xhci_hcd/4p, 5000M
/:  Bus 03.Port 1: Dev 1, Class=root_hub, Driver=xhci_hcd/4p, 480M
    |__ Port 1: Dev 2, If 0, Class=Hub, Driver=hub/4p, 480M
        |__ Port 1: Dev 4, If 0, Class=Hub, Driver=hub/4p, 480M
            |__ Port 1: Dev 5, If 1, Class=Human Interface Device, Driver=usbhid, 12M
            |__ Port 1: Dev 5, If 2, Class=Human Interface Device, Driver=usbhid, 12M
            |__ Port 1: Dev 5, If 0, Class=Human Interface Device, Driver=usbhid, 12M
            |__ Port 2: Dev 6, If 0, Class=Human Interface Device, Driver=usbhid, 12M
            |__ Port 2: Dev 6, If 1, Class=Human Interface Device, Driver=usbhid, 12M
    |__ Port 2: Dev 3, If 0, Class=Human Interface Device, Driver=usbhid, 12M
/:  Bus 02.Port 1: Dev 1, Class=root_hub, Driver=ehci-pci/2p, 480M
    |__ Port 1: Dev 2, If 0, Class=Hub, Driver=hub/6p, 480M
/:  Bus 01.Port 1: Dev 1, Class=root_hub, Driver=ehci-pci/2p, 480M
    |__ Port 1: Dev 2, If 0, Class=Hub, Driver=hub/8p, 480M
        |__ Port 8: Dev 3, If 0, Class=Hub, Driver=hub/2p, 480M
            |__ Port 1: Dev 4, If 0, Class=Hub, Driver=hub/3p, 12M
                |__ Port 3: Dev 8, If 2, Class=Vendor Specific Class, Driver=btusb, 12M
                |__ Port 3: Dev 8, If 0, Class=Vendor Specific Class, Driver=btusb, 12M
                |__ Port 3: Dev 8, If 3, Class=Application Specific Interface, Driver=, 12M
                |__ Port 3: Dev 8, If 1, Class=Wireless, Driver=btusb, 12M
            |__ Port 2: Dev 5, If 0, Class=Human Interface Device, Driver=usbhid, 1.5M


sudo dmesg | grep /input/
...
[    3.053086] input: RAPOO RAPOO 2.4G Wireless Device as /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1.1/3-1.1.2/3-1.1.2:1.0/0003:24AE:2000.0008/input/input11
[    3.115540] input: RAPOO RAPOO 2.4G Wireless Device Mouse as /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1.1/3-1.1.2/3-1.1.2:1.1/0003:24AE:2000.0009/input/input12
[    3.115638] input: RAPOO RAPOO 2.4G Wireless Device System Control as /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1.1/3-1.1.2/3-1.1.2:1.1/0003:24AE:2000.0009/input/input13
[    3.172436] input: RAPOO RAPOO 2.4G Wireless Device Consumer Control as /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1.1/3-1.1.2/3-1.1.2:1.1/0003:24AE:2000.0009/input/input14

cat /sys/bus/usb/devices/3-1/power/wakeup
disabled
echo enabled | sudo tee /sys/bus/usb/devices/3-1/power/wakeup
enabled
cat /sys/bus/usb/devices/3-1/power/wakeup
enabled
```

## Home Asssistant

Install virtual appliance following <https://bobcares.com/blog/add-qcow2-to-proxmox/>

Download appliance, uncompress on mac and copy to zbox ```scp haos_ova-11.0.qcow2 root@zbox.local:/var/lib/vz/template```

Create VM with no OS, 4 GB RAM, 2 CPU, no disk,  network, then import appliance

```bash
cd /var/lib/vz/template
qm importdisk 5220 haos_ova-11.0.qcow2 local-lvm
```

Attach disk vom image: Hardwared > unused disk , attach as VirtIO Block
Set BIOS to Uefi
Set boot oderder: Options > Boot Order > Disk/SCSI0


## Immich

Create non-privileged CT and Debian 12 Bookworm. 6 GB disk, 4 cores, 4 GB RAM no swap, static ip. Add config disk mounted to /infra, 800 GB, no backup. [Install docker in LXC](docker.md).

<https://immich.app/docs/install/docker-compose>


