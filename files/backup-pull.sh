#!/bin/bash

# A script to perform incremental backups using rsync
# Run on Jabba (NAS) to pull data from Dagobert (server)

# Copy to jabba: scp -O backup-pull.sh rsync@jabba:/var/services/homes/rsync/backup-pull.sh

set -o errexit
set -o nounset
set -o pipefail

readonly SOURCE_DIR="root@dagobert.local:/shares"
readonly BACKUP_DIR="/volume1/rsync_dagobert"
readonly DATETIME="$(date '+%Y-%m-%d_%H:%M:%S')"
readonly BACKUP_PATH="${BACKUP_DIR}/${DATETIME}"
readonly LATEST_LINK="${BACKUP_DIR}/latest"

start_time=$SECONDS
{
    mkdir -p "${BACKUP_DIR}"

    rsync -av --delete \
    "${SOURCE_DIR}/" \
    --link-dest "${LATEST_LINK}" \
    --copy-links \
    --exclude="@eaDir" \
    --exclude=".DS_Store" \
    "${BACKUP_PATH}"

    rm -rf "${LATEST_LINK}"
    ln -s "${BACKUP_PATH}" "${LATEST_LINK}"
    echo "${BACKUP_PATH} --> ${LATEST_LINK}"

    elapsed_time=$(( SECONDS - start_time ))
    echo "Backup completed in $elapsed_time seconds"
} 2>&1 | tee ${DATETIME}.log
