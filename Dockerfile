FROM ubuntu:18.04

LABEL maintainer Naba Das <hello@get-deck.com>

ENV DATE_TIMEZONE UTC
ENV DOCKER_BUILDKIT=0
ENV COMPOSE_DOCKER_CLI_BUILD=0

RUN apt-get update && apt-get install -y \
    mysql-server \
    mysql-client \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /var/lib/mysql \
    && mkdir -p /var/lib/mysql /var/run/mysqld \
	&& chown -R mysql:mysql /var/lib/mysql /var/run/mysqld \
	&& chmod 1777 /var/lib/mysql /var/run/mysqld 

VOLUME /var/lib/mysql

COPY config/ /etc/mysql/
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 3306 33060
CMD ["mysqld"]