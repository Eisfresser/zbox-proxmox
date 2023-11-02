# Install docker in lxc container

From https://docs.docker.com/engine/install/debian/#install-using-the-repository

```bash
apt-get update && apt upgrade -y
apt-get install ca-certificates curl gnupg sudo -y

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

From https://du.nkel.dev/blog/2021-03-25_proxmox_docker/. In LXC:

```bash
echo -e '{\n  "storage-driver": "overlay2"\n}' >> /etc/docker/daemon.json
```

On the Proxmox pyhsical machine, the overlay and aufs* Kernel modules must be enabled to support Docker-LXC-Nesting.

```bash
echo -e "overlay\naufs" >> /etc/modules-load.d/modules.conf
#Reboot Proxmox and verify that the modules are active:
lsmod | grep -E 'overlay|aufs'
```

Slow SSH login? Use ```journalctl``` and look for ```pam_systemd(sshd:session): Failed to create session: Failed to activate service 'org.freedesktop.login1' timed out (service_start_timeout=25000ms)```. If so, disable systemd-logind:

```bash
systemctl mask systemd-logind
pam-auth-update # ... and deselect Register user sessions in the systemd control group hierarchy
```

(from <https://gist.github.com/charlyie/76ff7d288165c7d42e5ef7d304245916>)

Run Lazydocker in container

```bash
docker run --rm -it -v \
/var/run/docker.sock:/var/run/docker.sock \
-v ./.lazydocker:/.config/jesseduffield/lazydocker \
lazyteam/lazydocker
```