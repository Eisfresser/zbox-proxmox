
# Dagobert with OpenMediaVault OMV

</br>

| Disk | Size | Type | Mount | Comment |  UUID |
| --- | --- | --- | --- | --- | --- |
| /dev/sda | 32.0 GiB | QEMU HARDDISK | Virtual |
| /dev/sdb1 | 7.28 TiB | WD WD80EFZZ-68BTXN0 | USB HDD | UUID="4bfc574a-336c-412d-84fb-5e76d94a55e8"
| /dev/sdc | 1.82 TiB | Samsung PSSD T7 | USB SSD |

</br>

| Share | Disk | Purpose |
| --- | --- | --- |
| homes | WD HDD 8 TB HDD | User home directories |
| public | WD HDD 8 TB HDD | Media files |
| timemachine | Samsung 2 TB SSD | Time Machine backups |

All shared folders are linked to /shares

```bash
mkdir /shares
ln -s /srv/dev-disk-by-uuid-4bfc574a-336c-412d-84fb-5e76d94a55e8/homes/ /shares/homes
ln -s /srv/dev-disk-by-uuid-4bfc574a-336c-412d-84fb-5e76d94a55e8/public/ /shares/public
ln -s /srv/dev-disk-by-uuid-204552fa-aba7-4106-9f4c-d923902c63aa/timemachine/ /shares/timemachine
```

</br>

Users

```bash
# import in omv
rolf;1026;tags;rolf.moser@gmail.com;password;/bin/bash;users;false
flieder;1027;tags;flieder10@gmail.com;password;/bin/bash;users;false
peta;1030;tags;peta.mcsharry@gmail.com;password;/bin/bash;users;false
#rsync;1031;tags;rsync@jabba.local;password;/bin/bash;users;false
```

</br>

## Install

Installed Debian 11 with OMV 6 in VM to be able to directly connect usb disks. Debian 12 will be supported as of OMV 7.

OMV installer stalls on DHCP6, one has to boot vm without network and configure a static ip. Therefore it is better to use Debian image and install OMV on top.

4 GB disk write back discard io thread ssd emu, 4 core, 4 GB RAM no baloon, 

In /etc/ssh/sshd_config, change PermitRootLogin to yes, restart sshd and copy ssh key to root

```bash
systemctl restart sshd
ssh-copy-id -i ~/.ssh/id_rsa.pub root@dagobert.local
```

Now change PermitRootLogin back to PermitRootLogin prohibit-password

### Set static ip address

```bash
apt install net-tools -y
ifconfig    # replace ens18 below with your network interface
cp /etc/network/interfaces /etc/network/interfaces.bak
nano /etc/network/interfaces
# replace iface ens18 inet dhcp with
allow-hotplug ens18
iface ens18 inet static
address 192.168.1.26
netmask 255.255.255.0
gateway 192.168.1.1
dns-nameservers 192.168.1.4
systemctl restart networking
```

## Install OMV

From <https://docs.openmediavault.org/en/latest/installation/on_debian.html>

```bash
apt-get install --yes gnupg wget
wget --quiet --output-document=- https://packages.openmediavault.org/public/archive.key | gpg --dearmor | tee "/etc/apt/trusted.gpg.d/openmediavault-archive-keyring.gpg"
cat <<EOF >> /etc/apt/sources.list.d/openmediavault.list
deb https://packages.openmediavault.org/public shaitan main
EOF
export LANG=C.UTF-8
export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none
apt-get update
apt-get --yes --auto-remove --show-upgraded \
    --allow-downgrades --allow-change-held-packages \
    --no-install-recommends \
    --option DPkg::Options::="--force-confdef" \
    --option DPkg::Options::="--force-confold" \
    install openmediavault-keyring openmediavault
omv-confdbadm populate
omv-salt deploy run systemd-networkd
```

Connect to <https://dagobert.local:9090>

## Mount external disk

```bash
lsusb

Bus 002 Device 005: ID 174c:55aa ASMedia Technology Inc. ASM1051E SATA 6Gb/s bridge, ASM1053E SATA 6Gb/s bridge, ASM1153 SATA 3Gb/s bridge, ASM1153E SATA 6Gb/s bridge # Orico HDD Dock

Bus 004 Device 007: ID 2109:0715 VIA Labs, Inc. VL817 SATA Adaptor # Orico 3.5" USB-C HDD Case

ls -la /dev/disk/by-path/

lrwxrwxrwx 1 root root  10 May 18 19:51 pci-0000:04:00.0-usb-0:2:1.0-scsi-0:0:0:0-part1 -> ../../sdb1

lsblk 
```

### Cockpit - not used

```bash
apt update && apt upgrade -y
# cockpit
. /etc/os-release
echo "deb http://deb.debian.org/debian ${VERSION_CODENAME}-backports main" > /etc/apt/sources.list.d/backports.list
apt update
apt install -t ${VERSION_CODENAME}-backports cockpit -y
# allow login by root
sudo sed -i 's/^root/#root/' /etc/cockpit/disallowed-users
```
