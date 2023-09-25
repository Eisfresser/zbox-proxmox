#!/bin/bash

# sync autopirate
scp autopirate/*.yml root@autopirate.local:/autopirate/
scp autopirate/homepage/*.yaml root@autopirate.local:/autopirate/config/homepage/
scp autopirate/autopirate.sh root@autopirate.local:/autopirate/

ssh root@autopirate.local "mkdir -p /autopirate/downloads/plex-transcode"
ssh root@autopirate.local "mkdir -p /autopirate/downloads/plex-media"
ssh root@autopirate.local "mkdir -p /autopirate/downloads/jellyfin-transcode:"
ssh root@autopirate.local "mkdir -p /autopirate/config/plex/Library/Application Support/Plex Media Server"
ssh root@autopirate.local "ln -s /autopirate/downloads/plex-media /autopirate/config/plex/Library/Application\ Support/Plex\ Media\ Server/Media"
