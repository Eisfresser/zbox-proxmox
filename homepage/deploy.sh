#!/bin/bash

pushd .
cd ~/Projects/zbox-proxmox/homepage
ssh root@home.fqp.ch "mkdir -p /var/homepage/icons"
scp *.yaml root@home.fqp.ch:/var/homepage/
scp *.yml root@home.fqp.ch:/var/homepage/
scp ./icons/* root@home.fqp.ch:/var/homepage/icons/

if [ "$1" = "pull" ]; then
    ssh root@home.fqp.ch "\
                        docker compose -f /var/homepage/docker-compose.yml down && \
                        docker compose -f /var/homepage/docker-compose.yml pull && \
                        docker compose -f /var/homepage/docker-compose.yml up -d && \
                        docker image prune -f"
fi
popd
