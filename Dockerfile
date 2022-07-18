FROM debian:11-slim

ENV MONGO_USER mongodb
ENV MONGO_PACKAGE mongodb-org
ENV MONGO_VERSION 5.0.9

RUN addgroup --system $MONGO_USER && adduser --system $MONGO_USER && usermod -a -G $MONGO_USER $MONGO_USER

RUN apt-get update -y
RUN apt-get install --no-install-recommends -y dirmngr gnupg apt-transport-https software-properties-common ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://www.mongodb.org/static/pgp/server-5.0.asc | apt-key add -

RUN add-apt-repository 'deb https://repo.mongodb.org/apt/debian buster/mongodb-org/5.0 main'
RUN apt-get update -y
RUN apt-get install -y \
		${MONGO_PACKAGE}=$MONGO_VERSION \
		${MONGO_PACKAGE}-server=$MONGO_VERSION \
		${MONGO_PACKAGE}-shell=$MONGO_VERSION \
		${MONGO_PACKAGE}-mongos=$MONGO_VERSION \
		${MONGO_PACKAGE}-tools=$MONGO_VERSION \
	&& rm -f /usr/local/bin/systemctl \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /var/lib/mongodb \
	&& mv /etc/mongod.conf /etc/mongod.conf.orig
RUN apt-get clean

RUN apt-get purge --auto-remove -y python3
RUN rm -rf /usr/local/lib/python3.7

RUN mkdir -p /data/db /data/configdb \
	&& chown -R $MONGO_USER:$MONGO_USER /data/db /data/configdb

RUN mkdir -p /data/db/
COPY docker-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN chown $MONGO_USER:$MONGO_USER /var/log /data/db
ENV PATH=/usr/local/bin:$PATH

ENTRYPOINT ["docker-entrypoint.sh"]

USER $MONGO_USER:$MONGO_USER

EXPOSE 27017
CMD ["mongod"]
