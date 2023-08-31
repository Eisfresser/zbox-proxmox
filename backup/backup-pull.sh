#!/bin/bash

# A script to perform incremental backups using rsync
# Run on Jabba (NAS) to pull data from Dagobert (server)
# No need to configure rsync service on omv (dagobert)
#
# User rsync@jabba must be able to ssh to root@dagobert without password, so
# add the public key of rsync@jabba to the authorized_keys file of root@dagobert
# DSM does not have ssh-copy-id, so 
# cat .ssh/id_rsa.pub | ssh root@dagobert 'cat >> /root/.ssh/authorized_keys'
#
# Copy source to jabba: 
#   scp -O backup/backup-pull.sh rsync@jabba:/var/services/homes/rsync/backup-pull.sh && scp -O backup/changes.py rsync@jabba:/var/services/homes/rsync/changes.py

set -o errexit
set -o nounset
set -o pipefail

readonly SOURCE_DIR="root@dagobert.local:/shares"
readonly BACKUP_DIR="/volume1/rsync_dagobert"
readonly DATETIME="$(date '+%Y-%m-%d_%H:%M:%S')"
readonly BACKUP_PATH="${BACKUP_DIR}/${DATETIME}"
readonly LATEST_LINK="${BACKUP_DIR}/latest"
readonly LOGFILE="logs/${DATETIME}.log"

START=$SECONDS

exec > >(tee "$LOGFILE") 2>&1

echo "Starting backup at $(date)"
echo "----------------------------------------"
echo "Source: ${SOURCE_DIR}"
echo "Destination: ${BACKUP_PATH}"
echo "Latest link: ${LATEST_LINK}"
echo "Logfile: ${LOGFILE}"
echo "rsync version: $(rsync --version | head -n 1)"
echo "----------------------------------------"
mkdir -p "${BACKUP_DIR}"

rsync -av \
    "${SOURCE_DIR}/" \
    --link-dest "${LATEST_LINK}" \
    --copy-links \
    --exclude="@eaDir" \
    --exclude=".DS_Store" \
    --exclude="._*" \
    "${BACKUP_PATH}" 

rm -rf "${LATEST_LINK}"
ln -s "${BACKUP_PATH}" "${LATEST_LINK}"
ELAPSED=$(( SECONDS - START ))
echo "----------------------------------------"
df -h ${BACKUP_DIR}
echo "$(date) Backup completed in $ELAPSED seconds"
echo "----------------------------------------"
python changes.py
echo "----------------------------------------"
