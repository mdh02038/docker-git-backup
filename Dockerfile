FROM ubuntu:14.04
MAINTAINER Mark Hummel <mdh@raquette.com>


ENV DEBIAN_FRONTEND noninteractive
ENV PATH /repo

RUN 'apt-get update \
    && apt-get install -yq --no-install-recommends git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*'

VOLUME /status
VOLUME /repo

ADD start.sh /start.sh

ENTRYPOINT ["/start.sh"]
