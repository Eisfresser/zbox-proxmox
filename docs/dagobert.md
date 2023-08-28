
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
rsync;1031;tags;rsync@jabba.local;password;/bin/bash;users;false
```

```



</br>

## Install

Installed as VM to be able to directly connect usb disks.

### Copy ssh key

```bash
In /etc/ssh/sshd_config, change PermitRootLogin to yes
```bash
# copy my ssh public key to root@dagobert.local
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

Connect to <https://dagobert.local:9090>

## Mount external disk

```bash
lsusb

Bus 002 Device 005: ID 174c:55aa ASMedia Technology Inc. ASM1051E SATA 6Gb/s bridge, ASM1053E SATA 6Gb/s bridge, ASM1153 SATA 3Gb/s bridge, ASM1153E SATA 6Gb/s bridge # Orico HDD Dock

Bus 004 Device 007: ID 2109:0715 VIA Labs, Inc. VL817 SATA Adaptor # Orico 3.5" USB-C HDD Case

ls -la /dev/disk/by-path/

lrwxrwxrwx 1 root root  10 May 18 19:51 pci-0000:04:00.0-usb-0:2:1.0-scsi-0:0:0:0-part1 -> ../../sdb1

lsblk 

sdb                             8:16   0  3.6T  0 disk
└─sdb1                          8:17   0  3.6T  0 part

blkid

/dev/sdb1: LABEL="1.42.6-25556" UUID="c3743a56-3be1-4faa-ad68-a83664cddc99" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="37dab241-931f-4c50-815e-a4d82059ed13"
```

Add to /etc/fstab

```bash
# usb hdd 8tb
UUID="4bfc574a-336c-412d-84fb-5e76d94a55e8" /mnt/hdd ext4 defaults 0 0
# hd dock
UUID="c3743a56-3be1-4faa-ad68-a83664cddc99" /mnt/dock ext4 defaults 0 0
```


### Import data from external disk

```bash
mount UUID="c3743a56-3be1-4faa-ad68-a83664cddc99" /hddock
mount -t nfs 192.168.1.18:/volume1/autopirate /nfs/autopirate
rsync --stats -v -h -a /nfs/autopirate /hddock
```



## Backup to Jabba

Pull backup from Jabba with [rsycn backup script](../files/backup-pull.sh)
Script is executied by DSM in a daily task. User rsync, folder /volume1/homes/rsync. Log files go to ./logs

List changed files between two dates

```bash
ssh rsync@jabba "python" < files/changes.py
```