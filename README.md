# ZBOX with Proxmox

## Install

Follow node installations instructions from [minicluster](../minicluster/docs/Installation.md)
Note that minicluster ansible commands cover zbox, but not other commands like start and stop.
Packages to install manually: ```apt install tasksel conky-all -y```.
Copy [conky.conf](files/conky.conf) to ```~/.config/conky/conky.conf```.

Setup and update with ```ansible-playbook ansible/setup.yml```

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

mount -t nfs 192.168.1.18:/autopirate /autopirate

```

Add to /etc/fstab: ```192.168.1.18:/volume1/autopirate/media  /autopirate/media  nfs  defaults``` (use tabs not blanks)
Use ```mount -a```to test fstab without rebooting.

Create autopirate user ```useradd -u 1027 -g users autopirate````


