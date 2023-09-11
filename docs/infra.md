
# Infra

Runs unifi

Create non-privileged CT and Debian 12 Bookworm

4 GB disk, 4 cores, 4 GB RAM no swap, static ip

Add config disk mounted to /infra, 4 GB, backup

[Install docker in LXC](docker.md)

</br>

## Unifi Controller

Self hosted unifi management console server. 

Note that the app can not be installed easily on debain 11 or 12 due to missing dependencies. It requires mongo db < 4 and openjdk 11. See <https://help.ui.com/hc/en-us/articles/220066768> and <https://glennr.nl/s/unifi-network-controller>.

Deploy with ```ìnfra/deploy.sh```, update by ```ssh root@infra "cd /infra/ && ./infra.sh down && ./infra.sh pull && ./infra.sh up"```

Access unifi controller at <https://infra.local:8443/>

For Unifi to adopt other devices, e.g. an Access Point, it is required to change the inform IP address. Because Unifi runs inside Docker by default it uses an IP address not accessible by other devices. To change this go to Settings > System > Advanced and set the Inform Host to a hostname or IP address accessible by your devices. Additionally the checkbox "Override" has to be checked, so that devices can connect to the controller during adoption (devices use the inform-endpoint during adoption).


## Nginx Proxy Manager

https://github.com/NginxProxyManager/nginx-proxy-manager

Admin ui <http://192.168.1.25:81>
Email:    admin@example.com
Password: changeme

