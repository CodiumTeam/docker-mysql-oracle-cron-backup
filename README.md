### Project origin and motivation

This project starts as a fork of [fradelg/docker-mysql-cron-backup](https://github.com/fradelg/docker-mysql-cron-backup) but for Oracle's Mysql.
Motivated by some recent changes on mysql 8.4 where using mariadb-dump with `--master-data` will not work as `SHOW MASTER STATUS` has been removed in favor of `SHOW BINLOG STATUS`.

Changes from parent project:

 - removed restore capabilities (aim for simplicity and low maintenance)

# mysql-cron-backup

Run mysqldump to backup your databases periodically using the cron task manager in the container. Your backups are saved in `/backup`. You can mount any directory of your host or a docker volumes in /backup. Othwerwise, a docker volume is created in the default location.

## Usage:

```bash
docker container run -d \
       --env MYSQL_USER=root \
       --env MYSQL_PASS=my_password \
       --link mysql
       --volume /path/to/my/backup/folder:/backup
       fradelg/mysql-cron-backup
```

### Healthcheck

Healthcheck is provided as a basic init control.
Container is **Healthy** after the database init phase, that is after `INIT_BACKUP` happends without check if there is an error, **Starting** otherwise. Not other checks are actually provided.

## Variables


- `MYSQL_HOST`: The host/ip of your mysql database.
- `MYSQL_HOST_FILE`: The file in container where to find the host of your mysql database (cf. docker secrets). You should use either MYSQL_HOST_FILE or MYSQL_HOST (see examples below).
- `MYSQL_PORT`: The port number of your mysql database.
- `MYSQL_USER`: The username of your mysql database.
- `MYSQL_USER_FILE`: The file in container where to find the user of your mysql database (cf. docker secrets). You should use either MYSQL_USER_FILE or MYSQL_USER (see examples below).
- `MYSQL_PASS`: The password of your mysql database.
- `MYSQL_PASS_FILE`: The file in container where to find the password of your mysql database (cf. docker secrets). You should use either MYSQL_PASS_FILE or MYSQL_PASS (see examples below).
- `MYSQL_DATABASE`: The database name to dump. Default: `--all-databases`.
- `MYSQL_DATABASE_FILE`: The file in container where to find the database name(s) in your mysql database (cf. docker secrets). In that file, there can be several database names: one per line. You should use either MYSQL_DATABASE or MYSQL_DATABASE_FILE (see examples below).
- `MYSQLDUMP_OPTS`: Command line arguments to pass to mysqldump (see [mysqldump documentation](https://dev.mysql.com/doc/refman/8.0/en/mysqldump.html)).
- `MYSQL_SSL_OPTS`: Command line arguments to use [SSL](https://dev.mysql.com/doc/refman/5.6/en/using-encrypted-connections.html).
- `CRON_TIME`: The interval of cron job to run mysqldump. `0 3 * * sun` by default, which is every Sunday at 03:00. It uses UTC timezone.
- `MAX_BACKUPS`: The number of backups to keep. When reaching the limit, the old backup will be discarded. No limit by default.
- `INIT_BACKUP`: If set, create a backup when the container starts.
- `EXIT_BACKUP`: If set, create a backup when the container stops.
- `TIMEOUT`: Wait a given number of seconds for the database to be ready and make the first backup, `10s` by default. After that time, the initial attempt for backup gives up and only the Cron job will try to make a backup.
- `GZIP_LEVEL`: Specify the level of gzip compression from 1 (quickest, least compressed) to 9 (slowest, most compressed), default is 6.
- `USE_PLAIN_SQL`: If set, back up plain SQL files without gzip.
- `TZ`: Specify TIMEZONE in Container. E.g. "Europe/Berlin". Default is UTC.
