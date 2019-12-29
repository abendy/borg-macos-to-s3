#!/bin/bash

# Exit immediately on errors
set -e

function check_last () {
  if ps ax | grep $0 | grep -v $$ | grep bash | grep -v grep > /dev/null; then
    echo 'Backup already running'
    exit 1;
  fi
}

function check_requirements () {
  which aws &> /dev/null
  if [ $? -ne 0 ]; then
    fail 'aws cli tool needs to be installed. See documentation.'
  fi

  which base64 &> /dev/null
  if [ $? -ne 0 ]; then
    fail 'base64 tool needs to be installed. See documentation.'
  fi

  # Test for environment variables file
  if [ ! -f "${BORG_ENV_FILE}" ]; then
    fail 'No environment variables file. Copy and edit the provided environment variables sample file. See documentation.'
  fi

  # Test for includes file
  if [ ! -f "${BORG_INCLUDES}" ]; then
    fail 'No includes file. Copy and edit the provided sample includes file. See documentation.'
  fi

  # Test for excludes file
  if [ ! -f "${BORG_EXCLUDES}" ]; then
    fail 'No excludes file. Copy and edit the provided sample excludes file. See documentation.'
  fi

  # Test for backup repository
  if [ -z "${BORG_REPO}" ]; then
    fail 'No backup repository defined. Fill out the .env file. See documentation.'
  fi

  # Test for S3 bucket
  if [ -z "${BORG_S3_BUCKET}" ]; then
    fail 'No S3 bucket defined. Fill out the .env file. See documentation.'
  fi

  # Test for emails
  if [ -z "${BORG_FROM_EMAIL}" -o -z "${BORG_TO_EMAIL}" ]; then
    fail 'No From or To defined. Fill out the .env file. See documentation.'
  fi
}

function main () {
  # Truncate log file
  : > ${BORG_LOG_FILE}

  # Backup
  borg create                                                   \
    --compression zlib,6                                        \
    --exclude-caches                                            \
    --exclude-from ${BORG_EXCLUDES}                             \
    --filter AME                                                \
    --patterns-from ${BORG_INCLUDES}                            \
    --show-rc                                                   \
    --stats                                                     \
    --verbose                                                   \
    ::${BORG_BACKUP_NAME}                                       \
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
    aws s3 sync ${BORG_REPO} s3://${BORG_S3_BUCKET}             \
      --delete                                                  \
      --no-progress                                             \
      >> ${BORG_LOG_FILE}

  success 'Sync complete'
}

function alert () {
  FILENAME=$(basename "${BORG_LOG_FILE%}")
  ATTACHMENT=`$BORG_LOG_FILE | /usr/bin/base64`
  BODY=`echo "$1" | /usr/bin/base64`

  TEMPLATE="ses-email-template.json"
  TMPFILE="/tmp/ses-$(date +%s)"

  cp $TEMPLATE $TMPFILE

  sed -i -e "s/{SUBJECT}/$1/g" $TMPFILE
  sed -i -e "s/{FROM}/${BORG_FROM_EMAIL}/g" $TMPFILE
  sed -i -e "s/{RECVS}/${BORG_TO_EMAIL}/g" $TMPFILE
  sed -i -e "s/{BODY}/$BODY/g" $TMPFILE
  sed -i -e "s/{FILENAME}/$FILENAME/g" $TMPFILE
  sed -i -e "s/{ATTACHMENT}/$ATTACHMENT/g" $TMPFILE

  aws ses send-raw-email --raw-message file://$TMPFILE
}

function success () {
  printf "\n%s\n\n" "[ OK ] $1" \
    2>&1 | tee -a ${BORG_LOG_FILE}
}

function fail () {
  printf "\n%s\n\n" "[ FAIL ] $1"  \
    2>&1 | tee -a ${BORG_LOG_FILE}

  exit 1
}

RN=$(date '+%Y-%m-%d-%H:%M:%S')

export BORG_ENV_FILE='/usr/local/etc/borg/.env'
export BORG_INCLUDES='/usr/local/etc/borg/backup.includes'
export BORG_EXCLUDES='/usr/local/etc/borg/backup.excludes'
export BORG_LOG_FILE="/usr/local/var/log/borg.log"

source ${BORG_ENV_FILE}

# Exit if borg is already running
check_last

check_requirements

main "$@";

alert "Borg backup complete at $(date '+%Y-%m-%d-%H:%M:%S')"

exit 0;
