#!/bin/bash
set -e
echo "Starting apt-cacher-ng..."
exec start-stop-daemon --start \
    --exec "$(command -v apt-cacher-ng)" -- -c /etc/apt-cacher-ng 
echo "apt-cacher-ng done."