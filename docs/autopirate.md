
# Autopirate

Runs qbittorrent, prowlarr, sonarr, radarr, readarr, plex, filebrowser, homepage.

Create privileged CT with and features: nesting=1

</br>

## Install docker

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

</br>

## Mount NFS

From https://theorangeone.net/posts/mount-nfs-inside-lxc/

```bash
mkdir /autopirate
apt install nfs-common -y

mount -t nfs 192.168.1.18:/volume1/autopirate /autopirate

```

Add to /etc/fstab: ```192.168.1.18:/volume1/autopirate/media  /autopirate/media  nfs  defaults``` (use tabs not blanks)
Use ```mount -a```to test fstab without rebooting.

</br>

## Create user and locale

```bash
groupadd -g 100 users
useradd -u 1027 -g users autopirate```
echo "LC_ALL=en_US.UTF-8" >> /etc/environment
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
locale-gen en_US.UTF-8
```

Modify user id of existing user ```usermod -u 1027 flieder```

</br>

## Start stop

```bash
cd /autopirate
docker compose -f readarr.yml up
./autopirate.sh up
```

</br>

## Update

```bash
ssh root@autopirate.local
apt update && apt upgrade -y && apt autoremove -y
cd /autopirate/
for file in *.yml; do docker compose -f "$file" down; done
docker rmi $(docker images -q)
for file in *.yml; do docker compose -f "$file" up -d; done
```

<br>

## Sync calibre library

Run on mac in home folder:

```bash
ssh root@autopirate.local apt install rsync
rsync -rv ~/Calibre\ Library/ root@autopirate.local:/autopirate/media/books/
```

with calibresync.sh script in /usr/local/sbin
