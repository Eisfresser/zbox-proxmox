#!/bin/bash

# A script to perform incremental backups using rsync
# Run on Jabba (NAS) to pull data from Dagobert (server)

# Copy to jabba: 
#   scp -O backup-pull.sh rsync@jabba:/var/services/homes/rsync/backup-pull.sh
#   scp -O changes.py     rsync@jabba:/var/services/homes/rsync/changes.py

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

2023-06-10_04:10:35  2023-06-29_04:10:02  2023-07-01_11:18:56  2023-07-03_04:10:01  2023-07-05_04:10:01  2023-07-07_04:10:01  latest
2023-06-12_04:10:02  2023-06-30_15:19:05  2023-07-02_04:10:36  2023-07-04_04:10:36  2023-07-06_04:10:01  2023-07-07_12:26:32