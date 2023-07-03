# ZBOX with Proxmox

1. [Install](#install)
2. [Pi Hole - DNS/DHCP](#pi-hole)
3. [Autopirate - Media Management](docs/autopirate.md)
4. [Curator - ElasticSearch Monitoring](docs/curator.md)
5. [Dagobert - OMV NAS](docs/dagobert.md)

</br>

## Install

Follow node installations instructions from [minicluster](../minicluster/docs/Installation.md)
Note that minicluster ansible commands cover zbox, but not other commands like start and stop.
Packages to install manually: ```apt install tasksel conky-all -y```.
Copy [conky.conf](files/conky.conf) to ```~/.config/conky/conky.conf```.

Setup and update with ```ansible-playbook ansible/setup.yml```

</br>

## Pi Hole

Login with ssh key 

```bash
ssh root@pi.hole
apt update && apt upgrade -y && apt autoremove -y
pihole -up
```
