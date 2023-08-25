# Unifi Console

Self hosted unifi management console server. 

Note that the app can not be installed easily on debain 11 or 12 due to missing dependencies. It requires mongo db < 4 and openjdk 11. <https://help.ui.com/hc/en-us/articles/220066768> <https://glennr.nl/s/unifi-network-controller>

Install LXC with docker as described in (autopirate.md)[docs/autopirate.md] and run a docker container. 

Loging to unifi deivces with ```ssh admin@192.168.1.6```and ssh key from yualeus.
