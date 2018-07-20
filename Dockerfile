FROM ubuntu:14.04
MAINTAINER Mark Hummel <mdh@raquette.com>

ENV DEBIAN_FRONTEND noninteractive
ENV PATH /repo

RUN apt-get update \
    && apt-get install -yq --no-install-recommends python-pip mysql-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && apt-get git

VOLUME /status
VOLUME /repo

ADD start.sh /start.sh

ENTRYPOINT ["/start.sh"]
