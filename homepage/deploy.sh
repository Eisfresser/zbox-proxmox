#!/bin/bash


ssh root@home.fqp.ch "mkdir -p /var/homepage"
scp homepage/*.yaml root@home.fqp.ch:/var/homepage/
scp homepage/*.yml root@home.fqp.ch:/var/homepage/
ssh root@home.fqp.ch "\
                    docker compose -f /var/homepage/homepage.yml down && \
                    docker compose -f /var/homepage/homepage.yml pull && \
                    docker compose -f /var/homepage/homepage.yml up -d && \
                    docker image prune -f"
