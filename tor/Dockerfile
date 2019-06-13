FROM alpine@sha256:769fddc7cc2f0a1c35abb2f91432e8beecf83916c421420e6a6da9f8975464b6 AS builder

ARG TOR_VER=0.3.5.8
ARG TORGZ=https://dist.torproject.org/tor-$TOR_VER.tar.gz

RUN apk --no-cache add --update \
  alpine-sdk gnupg libevent libevent-dev zlib zlib-dev openssl openssl-dev

RUN wget $TORGZ.asc && wget $TORGZ

# Verify tar signature and install tor
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys 0x6AFEE6D49E92B601 \
  && gpg --verify tor-$TOR_VER.tar.gz.asc || { echo "Couldn't verify sig"; exit; } \
  && tar xfz tor-$TOR_VER.tar.gz && cd tor-$TOR_VER \
  && ./configure && make install

FROM alpine@sha256:769fddc7cc2f0a1c35abb2f91432e8beecf83916c421420e6a6da9f8975464b6

RUN apk --no-cache add --update \
  bash alpine-sdk gnupg libevent libevent-dev zlib zlib-dev openssl openssl-dev

RUN adduser -s /bin/bash -D -u 2000 tor
RUN mkdir -p /var/run/tor && chown -R tor:tor /var/run/tor && chmod 2700 /var/run/tor
RUN mkdir -p /home/tor/tor && chown -R tor:tor /home/tor/tor  && chmod 2700 /home/tor/tor

COPY ./torrc /home/tor/tor/torrc
COPY --from=builder /usr/local/ /usr/local/

USER tor
