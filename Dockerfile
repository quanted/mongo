FROM debian:10.11-slim

ENV MONGO_USER mongodb
ENV MONGO_PACKAGE mongodb-org
ENV MONGO_VERSION 5.0.6

RUN addgroup --system $MONGO_USER && adduser --system $MONGO_USER && usermod -a -G $MONGO_USER $MONGO_USER

RUN apt update -y
RUN apt install --no-install-recommends -y dirmngr gnupg apt-transport-https software-properties-common ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://www.mongodb.org/static/pgp/server-5.0.asc | apt-key add -

#RUN apt-get install -y libcurl4 openssl liblzma5 tar curl
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

RUN mkdir -p /data/db /data/configdb \
	&& chown -R $MONGO_USER:$MONGO_USER /data/db /data/configdb

#https://repo.mongodb.org/apt/debian/dists/buster/mongodb-org/5.0
#RUN apt-get install -y mongodb
#RUN curl https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-debian10-5.0.6.tgz --output /tmp/mongodb.tgz
#RUN cd /tmp && tar -zvxf mongodb.tgz
#RUN cp /tmp/mongodb-linux-x86_64-debian10-5.0.6/bin/* /usr/bin/
#RUN rm -rf /tmp/*

RUN mkdir -p /data/db/

RUN chown $MONGO_USER:$MONGO_USER /var/log /data/db

#ENTRYPOINT ["/usr/bin/mongod", "-v", "--dbpath", "/data/db", "--logpath", "/var/log/mongod.log", ""]

USER $MONGO_USER:$MONGO_USER

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 27017
CMD ["mongod"]
