#!/bin/bash

# Exit immediately on errors
set -e

function success () {
  echo -e "[ \033[00;32mOK\033[0m ] $1\n"
}

function fail () {
  echo -e "[\033[0;31mFAIL\033[0m] $1\n"
  exit 1
}

# Vars
ENV_FILE='/usr/local/etc/borg/.env'
if [ ! -f "${ENV_FILE}" ]; then
  fail 'No environment variables file. Copy and edit the provided environment variables sample file. See documentation.'
fi

source ${ENV_FILE}

# Excludes
EXCLUDES='/usr/local/etc/borg/backup.excludes'
if [ ! -f "${EXCLUDES}" ]; then
  fail 'No excludes file. Copy and edit the provided sample excludes file. See documentation.'
fi

# Repo
if [ -z "${BORG_REPO}" ]; then
  fail 'No backup repository defined.'
fi

# S3 bucket
if [ -z "${S3_BUCKET}" ]; then
  fail 'No S3 bucket defined.'
fi

# Backup
borg create                                                   \
  --compression zlib,6                                        \
  --exclude-caches                                            \
  --exclude-from ${EXCLUDES}                                  \
  --filter AME                                                \
  --show-rc                                                   \
  --stats                                                     \
  --verbose                                                   \
  ::${BACKUP}                                                 \
  /Users/abendy                                               \
  /etc                                                        \
  /usr                                                        \
  2>> ${LOG_FILE}

success 'Backup complete'

# Prune
borg prune -v --list ${BORG_REPO} --prefix 'macos-' --keep-daily=14 --keep-weekly=4 --keep-monthly=6

success 'Prune complete'

# Sync to S3
borg with-lock ${BORG_REPO} aws s3 sync ${BORG_REPO} s3://${S3_BUCKET} --delete

success 'Sync complete'

exit 0;
