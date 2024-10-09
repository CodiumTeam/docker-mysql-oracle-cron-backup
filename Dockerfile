ARG MYSQL_VERSION=8.4

FROM ubuntu:latest AS dockerize-installer
ARG DOCKERIZE_VERSION=0.8.0
WORKDIR /tmp
RUN apt-get update && apt-get install wget -y
RUN wget -O dockerize.tar.gz \
    https://github.com/jwilder/dockerize/releases/download/v${DOCKERIZE_VERSION}/dockerize-linux-$(dpkg --print-architecture)-v${DOCKERIZE_VERSION}.tar.gz \
    && tar -xzf dockerize.tar.gz


FROM mysql:${MYSQL_VERSION}
MAINTAINER "Hugo Chinchilla <hugo@codium.team>"

COPY --from=dockerize-installer /tmp/dockerize /usr/local/bin
COPY --from=webdevops/go-crond:23.12.0-debian /usr/local/bin/go-crond /usr/local/bin/go-crond

ENV CRON_TIME="0 3 * * sun" \
    MYSQL_HOST="mysql" \
    MYSQL_PORT="3306" \
    TIMEOUT="10s" \
    MYSQLDUMP_OPTS="--quick"

RUN mkdir /app /backup
COPY ["run.sh", "backup.sh", "delete.sh", "/app/"]
RUN chmod 777 /backup && \
    chmod 755 /app/run.sh /app/backup.sh /app/delete.sh

VOLUME ["/backup"]
WORKDIR /app

HEALTHCHECK --interval=2s --retries=1800 \
	CMD stat /app/HEALTHY.status || exit 1

CMD dockerize -wait tcp://${MYSQL_HOST}:${MYSQL_PORT} -timeout ${TIMEOUT} /app/run.sh
