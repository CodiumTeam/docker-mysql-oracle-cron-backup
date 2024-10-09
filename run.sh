#!/bin/bash

if [ "${INIT_BACKUP:-0}" -gt "0" ]; then
  echo "=> Create a backup on the startup"
  /app/backup.sh
fi

function final_backup {
    echo "=> Captured trap for final backup"
    echo "=> Requested last backup at $(date "+%Y-%m-%d %H:%M:%S")"
    exec /app/backup.sh
    exit 0
}

if [ -n "${EXIT_BACKUP}" ]; then
  echo "=> Listening on container shutdown gracefully to make last backup before close"
  trap final_backup SIGHUP SIGINT SIGTERM
fi

touch HEALTHY.status

echo "${CRON_TIME} /app/backup.sh" > /tmp/crontab.conf
echo "=> Running cron task manager in foreground"
go-crond --verbose --allow-unprivileged mysql:/tmp/crontab.conf
echo "Script is shutted down."
