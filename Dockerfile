FROM ubuntu:xenial
MAINTAINER Oliver Gugger <gugger@gmail.com>

ARG USER_ID
ARG GROUP_ID
ARG VERSION

ENV USER terracoin
ENV COMPONENT ${USER}
ENV HOME /${USER}

# add user with specified (or default) user/group ids
ENV USER_ID ${USER_ID:-1000}
ENV GROUP_ID ${GROUP_ID:-1000}

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -g ${GROUP_ID} ${USER} \
	&& useradd -u ${USER_ID} -g ${USER} -s /bin/bash -m -d ${HOME} ${USER}

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -x \
	&& apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		wget \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true

ENV VERSION ${VERSION:-0.12.1.5p}
RUN set -x \
    && mkdir -p /opt/${COMPONENT}/bin \
    && wget -O /opt/${COMPONENT}/bin/${COMPONENT}-cli "https://github.com/terracoin/terracoin/releases/download/${VERSION}/${COMPONENT}-cli" \
    && wget -O /opt/${COMPONENT}/bin/${COMPONENT}d "https://github.com/terracoin/terracoin/releases/download/${VERSION}/${COMPONENT}d" \
    && wget -O /opt/${COMPONENT}/bin/${COMPONENT}-qt "https://github.com/terracoin/terracoin/releases/download/${VERSION}/${COMPONENT}-qt" \
    && chmod +x /opt/${COMPONENT}/bin/*

RUN set -x \
    && apt-get update && apt-get install -y libboost-all-dev build-essential autoconf libtool pkg-config libssl-dev libevent-dev

RUN set -x \
	&& cd /tmp \
	&& wget http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz \
	&& tar xzvf db-4.8.30.NC.tar.gz \
	&& cd db-4.8.30.NC/build_unix/ \
	&& ../dist/configure --enable-cxx \
	&& make \
	&& make install

RUN ln -s /usr/local/BerkeleyDB.4.8 /usr/include/db4.8
RUN ln -s /usr/include/db4.8/include/* /usr/include
RUN ln -s /usr/include/db4.8/lib/* /usr/lib

RUN set -x \
    && apt-get update && apt-get install -y libminiupnpc-dev

EXPOSE 13333 13332

RUN set -x && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME ["${HOME}"]
WORKDIR ${HOME}
ADD ./bin /usr/local/bin
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["start-unprivileged.sh"]
