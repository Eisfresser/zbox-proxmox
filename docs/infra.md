
# Infra

Runs nginx proxy manager, unifi, apt-cacher-ng

DNS third level domain <https://infra.fqp.ch>

## LXC container

Create non-privileged CT and Debian 12 Bookworm. 4 GB disk, 4 cores, 4 GB RAM no swap, static ip. Add config disk mounted to /infra, 4 GB, backup. [Install docker in LXC](docker.md).

</br>

## Nginx Proxy Manager

https://github.com/NginxProxyManager/nginx-proxy-manager

Admin ui <http://192.168.1.25:81>
Email:    admin@example.com
Password: changeme

Create let's encrypt wildcard certificate for *.infra.fqp.ch.

Proxy config
| CName | Service | Redirect to |
---------------------------------
| unifi.infra.fqp.ch | Unifi Controller | unifi-controller:8443 |
| apt.infra.fqp.ch | Apt Cacher NG | apt-cacher-ng:3142 |

</br>

## Unifi Controller

Self hosted unifi management console server. 

Note that the app can not be installed easily on debain 11 or 12 due to missing dependencies. It requires mongo db < 4 and openjdk 11. See <https://help.ui.com/hc/en-us/articles/220066768> and <https://glennr.nl/s/unifi-network-controller>.

Deploy with ```ìnfra/deploy.sh```, update by ```ssh root@infra "cd /infra/ && ./infra.sh down && ./infra.sh pull && ./infra.sh up"```

Access unifi controller at <https://infra.local:8443/>

For Unifi to __adopt other devices__, it is required to __change the inform IP address__. Because Unifi runs inside Docker by default it uses an IP address not accessible by other devices. To change this go to Settings > System > Advanced and set the Inform Host to a hostname or IP address accessible by your devices. Additionally the checkbox "Override" has to be checked, so that devices can connect to the controller during adoption (devices use the inform-endpoint during adoption).

</br>

## Apt Cacher NG

Loosely following <https://github.com/sameersbn/docker-apt-cacher-ng>
Access apt cacher ng at <http://localhost:3142/>

Build and run container

```bash
cd infra/apt-cacher-ng
mkdir -p /tmp/apt-cacher-ng-cache
docker build . -t ghcr.io/eisfresser/zbox-proxmox/apt-cacher-ng:latest
docker run -d --name apt-cacher-ng -p 3142:3142 \
    -v /tmp/apt-cacher-ng-cache:/var/cache/apt-cacher-ng \
    ghcr.io/eisfresser/zbox-proxmox/apt-cacher-ng:latest
docker rm apt-cacher-ng
```

Push container to github, check if it is private <https://github.com/Eisfresser?tab=packages>

```bash
export $(xargs <.env)
echo $GITHUB_USERNAME $GITHUB_WRITE_DEL_PACKAGES_TOKEN
docker login --username $GITHUB_USERNAME --password $GITHUB_WRITE_DEL_PACKAGES_TOKEN ghcr.io
docker push ghcr.io/eisfresser/zbox-proxmox/apt-cacher-ng:latest
``` 
