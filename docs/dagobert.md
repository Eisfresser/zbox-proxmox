
# Dagobert with OpenMediaVault OMV

</br>

| Disk | Size | Type | Mount | Comment |
| --- | --- | --- | --- | --- |
| /dev/sda | 32.0 GiB | QEMU HARDDISK | Virtual |
| /dev/sdb | 7.28 TiB | WD WD80EFZZ-68BTXN0 | USB HDD |
| /dev/sdc | 1.82 TiB | Samsung PSSD T7 | USB SSD |

</br>

| Share | Disk | Purpose |
| --- | --- | --- |
| homes | WD HDD 8 TB HDD | User home directories |
| public | WD HDD 8 TB HDD | Media files |
| timemachine | Samsung 2 TB SSD | Time Machine backups |

All shared folders are linked to /shared

</br>

## Backup to Jabba

Pull backup from Jabba with [rsycn backup script](../files/backup-pull.sh)
Script is executied by DSM in a daily task. User rsync, folder /volume1/homes/rsync. Log files go to ./logs

List changed files between two dates

```bash
ssh rsync@jabba "python" < files/changes.py
```

</br>

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

### Import data from external disk

```bash
mount UUID="c3743a56-3be1-4faa-ad68-a83664cddc99" /hddock
mount -t nfs 192.168.1.18:/volume1/autopirate /nfs/autopirate
rsync --stats -v -h -a /nfs/autopirate /hddock
```
