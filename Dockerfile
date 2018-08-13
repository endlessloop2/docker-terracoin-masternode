FROM ubuntu:xenial
MAINTAINER Mateo León <mateo@endlessloop.me>
	
ENV VERSION ${VERSION:-0.12.1.8}
RUN wget -O /tmp/${COMPONENT}.tar.gz "https://terracoin.io/bin/terracoin-core-${VERSION}/terracoin-0.12.1-x86_64-linux-gnu.tar.gz" \
    && cd /tmp/ \
    && tar zxvf ${COMPONENT}.tar.gz \
    && mv /tmp/${COMPONENT}-* /opt/${COMPONENT} \
    && rm -rf /tmp/*

RUN apt-get update && apt-get install -y libminiupnpc-dev python-virtualenv git virtualenv cron \
    && mkdir -p /sentinel \
    && cd /sentinel \
    && git clone https://github.com/terracoin/sentinel.git . \
    && virtualenv ./venv \
    && ./venv/bin/pip install -r requirements.txt \
    && touch sentinel.log \
    && chown -R ${USER} /sentinel \
    && echo '* * * * * '${USER}' cd /sentinel && SENTINEL_DEBUG=1 ./venv/bin/python bin/sentinel.py >> sentinel.log 2>&1' >> /etc/cron.d/sentinel \
    && chmod 0644 /etc/cron.d/sentinel \
    && touch /var/log/cron.log
    
USER container
ENV  USER=container HOME=/home/container
EXPOSE 13333 13332


VOLUME ["${HOME}"]
WORKDIR ${HOME}
ADD ./bin /usr/local/bin

COPY ./entrypoint.sh /entrypoint.sh
CMD ["/bin/bash", "/entrypoint.sh"]
