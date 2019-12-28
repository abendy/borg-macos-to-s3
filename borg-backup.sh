#!/bin/bash

# Exit immediately on errors
set -e

RN=$(date '+%Y-%m-%d %H:%M:%S')

function main () {
  # Test for environment variables file
  ENV_FILE='/usr/local/etc/borg/.env'
  if [ ! -f "${ENV_FILE}" ]; then
    fail 'No environment variables file. Copy and edit the provided environment variables sample file. See documentation.'
  fi

  source ${ENV_FILE}

  # Test for includes file
  INCLUDES='/usr/local/etc/borg/backup.includes'
  if [ ! -f "${INCLUDES}" ]; then
    fail 'No includes file. Copy and edit the provided sample includes file. See documentation.'
  fi

  # Test for excludes file
  EXCLUDES='/usr/local/etc/borg/backup.excludes'
  if [ ! -f "${EXCLUDES}" ]; then
    fail 'No excludes file. Copy and edit the provided sample excludes file. See documentation.'
  fi

  # Test for backup repository
  if [ -z "${BORG_REPO}" ]; then
    fail 'No backup repository defined.'
  fi

  # Test for S3 bucket
  if [ -z "${S3_BUCKET}" ]; then
    fail 'No S3 bucket defined.'
  fi

  # Keep-alive: update existing `sudo` time stamp until the script has finished
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

  # Truncate log file
  : > ${BORG_LOG_FILE}

  # Backup
  borg create                                                   \
    --compression zlib,6                                        \
    --exclude-caches                                            \
    --exclude-from ${EXCLUDES}                                  \
    --filter AME                                                \
    --patterns-from ${INCLUDES}                                 \
    --list                                                      \
    --progress                                                  \
    --show-rc                                                   \
    --stats                                                     \
    --verbose                                                   \
    ::${BACKUP_NAME}                                            \
    2>> ${BORG_LOG_FILE}

  success 'Backup complete'

  # Prune
  borg prune                                                    \
    --keep-within 2d                                            \
    --keep-daily=14                                             \
    --keep-weekly=4                                             \
    --keep-monthly=6                                            \
    --list ${BORG_REPO}                                         \
    --prefix 'macos-{hostname}-'                                \
    --verbose                                                   \
    2>> ${BORG_LOG_FILE}

  success 'Prune complete'

  # Sync to S3
  borg with-lock ${BORG_REPO}                                   \
    aws s3 sync ${BORG_REPO} s3://${S3_BUCKET}                  \
      --delete                                                  \
      >> ${BORG_LOG_FILE}

  success 'Sync complete'

  alert "backup complete at ${RN}"
}

function alert () {
  aws ses send-email \
    --from "${FROM_EMAIL}" \
    --destination "ToAddresses=${TO_EMAIL}" \
    --message "Subject={Data=Borg $1,Charset=utf8},Body={Text={Data=$1,Charset=utf8},Html={Data=$1,Charset=utf8}}"
}

function success () {
  printf "\n%s\n\n" "[ OK ] $1" \
    2>&1 | tee -a ${BORG_LOG_FILE}
}

function fail () {
  printf "\n%s\n\n" "[ FAIL ] $1"  \
    2>&1 | tee -a ${BORG_LOG_FILE}
  alert $1
  exit 1
}

main "$@";

exit 0;
