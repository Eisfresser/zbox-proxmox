
# Autopirate

Runs qbittorrent, prowlarr, sonarr, radarr, readarr, plex, filebrowser, homepage.

Create privileged CT and Debian 12 Bookworm with and features: mount=nfs, nesting=1

4 GB disk, 4 cores, 4 GB RAM no swap, 

[Install docker in LXC](docker.md)
</br>

## Create user and locale

```bash
groupadd -g 100 users
useradd -u 1027 -g users flieder
echo "LC_ALL=en_US.UTF-8" >> /etc/environment
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
locale-gen en_US.UTF-8
```

Or modify user id of existing user ```usermod -u 1027 flieder```

</br>

## Create autopirate folder and mount NFS

```bash
mkdir /autopirate               # docker compose files and scripts
mkdir /autopirate/config        # mounted to containers for persitent config
mkdir /autopirate/config/homepage   # homepage config
mkdir /autopirate/media         # media files on dagobert
mkdir /autopirate/download      # download partition, add as resource to LXC
```

From <https://theorangeone.net/posts/mount-nfs-inside-lxc/>

```bash
mkdir /autopirate
apt install nfs-common -y
showmount -e 192.168.1.26
mount -v -t nfs 192.168.1.26:/export/public /autopirate/media
```

Add to /etc/fstab: ```192.168.1.26:/export/public  /autopirate/media  nfs  defaults``` (use tabs not blanks)
Use ```mount -a```to test fstab without rebooting.

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
apt-get update && apt-get upgrade -y && apt-get autoremove -y
cd /autopirate/
#for file in *.yml; do docker compose -f "$file" down; done
./autopirate.sh down
docker rmi $(docker images -q)
#for file in *.yml; do docker compose -f "$file" up -d; done
./autopirate.sh up
```

<br>


## qBittorrent

Default pwd admin:adminadmin, change to flieder
Bypass auth from localhost
192.168.1.0/24
172.18.0.0/16

## Jellyfin

No default pwd, refresh page to load setup wizard
Set pwd for flieder

## Prowlar

Authentication disabled for local network
Set pwd for flieder
Add piratebay indexer
Add apps, use autopirate.local as host name for both sides and get api key from app settings/general





## Sync calibre library

Run on mac in home folder:

```bash
ssh root@autopirate.local apt install rsync
rsync -rv ~/Calibre\ Library/ root@autopirate.local:/autopirate/media/books/
ssh root@autopirate.local docker kill calibre-web
```

with calibresync.sh script in /usr/local/sbin

## Reset calibre-web admin pwd

SSH into autopirate

```bash
docker exec
cd /app/calibre-web -it calibre-web /bin/bash
python3 ./cps.py -p /config/app.db  -s admin:<password>
```
