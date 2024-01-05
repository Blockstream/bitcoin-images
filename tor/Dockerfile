FROM alpine:3.18 AS builder

ARG TOR_VER
ARG DW_TORGZ=https://dist.torproject.org/tor-$TOR_VER.tar.gz
ARG DW_TORGZ_SHASUM=$DW_TORGZ.sha256sum
ARG DW_TORGZ_SHASUM_ASC=$DW_TORGZ_SHASUM.asc

ARG TORGZ=tor-$TOR_VER.tar.gz
ARG TORGZ_SHASUM=$TORGZ.sha256sum
ARG TORGZ_SHASUM_ASC=$TORGZ_SHASUM.asc

RUN apk --no-cache add --update \
  alpine-sdk gnupg libevent libevent-dev zlib zlib-dev openssl openssl-dev

RUN wget $DW_TORGZ && wget $DW_TORGZ_SHASUM && wget $DW_TORGZ_SHASUM_ASC

# Verify tar signature and install tor
# https://support.torproject.org/little-t-tor/verify-little-t-tor/
RUN gpg --keyserver keys.openpgp.org --recv-keys 2133BC600AB133E1D826D173FE43009C4607B1FB \
&& gpg --keyserver keys.openpgp.org --recv-keys 514102454D0A87DB0767A1EBBE6A0531C18A9179 \
  && gpg --keyserver keys.openpgp.org --recv-keys B74417EDDF22AC9F9E90F49142E86A2A11F48D36 \
  && gpg --verify $TORGZ_SHASUM_ASC || { echo "Couldn't verify sig"; exit 1; }
RUN sha256sum -c $TORGZ_SHASUM || { echo "SHA doesn't match"; exit 1; }
RUN tar xfz $TORGZ && cd tor-$TOR_VER \
  && ./configure && make -j $(nproc --all) install

FROM alpine:3.18

ARG TOR_VER
ENV TOR_VER=$TOR_VER

RUN apk --no-cache add --update \
  bash alpine-sdk gnupg libevent libevent-dev zlib zlib-dev openssl openssl-dev

RUN adduser -s /bin/bash -D -u 2000 tor
RUN mkdir -p /var/run/tor && chown -R tor:tor /var/run/tor && chmod 2700 /var/run/tor
RUN mkdir -p /home/tor/tor && chown -R tor:tor /home/tor/tor  && chmod 2700 /home/tor/tor

COPY ./torrc /home/tor/tor/torrc
COPY --from=builder /usr/local/ /usr/local/

USER tor
