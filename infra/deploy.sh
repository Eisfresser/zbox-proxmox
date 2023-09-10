#!/bin/bash

# sync autopirate
scp infra/*.yml root@infra.local:/infra/
scp infra/infra.sh root@infra.local:/infra/
ssh root@infra.local "chmod +x /infra/infra.sh && mkdir -p /infra/unifi"

