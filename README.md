# ZBOX with Proxmox

## Install

Follow node installations instructions from [minicluster](../minicluster/docs/Installation.md)
Note that minicluster ansible commands cover zbox, but not other commands like start and stop.
Packages to install manually: ```apt install tasksel conky-all -y```.
Copy [conky.conf](files/conky.conf) to ```~/.config/conky/conky.conf```.

Setup and update with ```ansible-playbook ansible/setup.yml```

## Pi Hole

Login with ssh key 

```bash
ssh root@pi.hole
apt update && apt upgrade -y && apt autoremove -y
pihole -up
```


## Autopirate

Runs qbittorrent, prowlarr, sonarr, radarr, readarr, plex, filebrowser, homepage.

Create privileged CT with and features: nesting=1

### Install docker

From https://docs.docker.com/engine/install/debian/#install-using-the-repository

```bash
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
````

From https://du.nkel.dev/blog/2021-03-25_proxmox_docker/

```bash
echo -e '{\n  "storage-driver": "overlay2"\n}' >> /etc/docker/daemon.json
```

### Mount NFS

From https://theorangeone.net/posts/mount-nfs-inside-lxc/

```bash
mkdir /autopirate
apt install nfs-common -y

mount -t nfs 192.168.1.18:/volume1/autopirate /autopirate

```

Add to /etc/fstab: ```192.168.1.18:/volume1/autopirate/media  /autopirate/media  nfs  defaults``` (use tabs not blanks)
Use ```mount -a```to test fstab without rebooting.

### Create user and locale

```bash
groupadd -g 100 users
useradd -u 1027 -g users autopirate```
echo "LC_ALL=en_US.UTF-8" >> /etc/environment
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
locale-gen en_US.UTF-8
```

Modify user id of existing user ```usermod -u 1027 flieder```

### Start stop

```bash
cd /autopirate
docker compose -f readarr.yml up
./autopirate.sh up
```

### Update

```bash
ssh root@autopirate.local
apt update && apt upgrade -y && apt autoremove -y
cd /autopirate/
for file in *.yml; do docker compose -f "$file" down; done
docker rmi $(docker images -q)
for file in *.yml; do docker compose -f "$file" up -d; done
```


## OpenMediaVault OMV

### Mount external disk

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

mount UUID="c3743a56-3be1-4faa-ad68-a83664cddc99" /hddock
mount -t nfs 192.168.1.18:/volume1/autopirate /nfs/autopirate
rsync --stats -v -h -a /nfs/autopirate /hddock

```

