FROM alpine:3.22 AS builder

ARG TOR_VERSION=0.4.9.11
ARG TOR_SHA256=2e6c1720118c812acf0079fd47cf91b6bfaba5d766c321c4d3d2a28d6a11a8ed
ARG TOR_SOURCE=https://dist.torproject.org/tor-${TOR_VERSION}.tar.gz

WORKDIR /src

RUN apk add --no-cache \
    build-base \
    ca-certificates \
    curl \
    gnupg \
    libevent-dev \
    libseccomp-dev \
    openssl-dev \
    xz-dev \
    zstd-dev \
    zlib-dev

# Verify the signed upstream checksum and the pinned source checksum before
# compiling.  The fingerprints are Tor release-signing keys.
RUN set -eux; \
    curl --fail --location --silent --show-error --remote-name "${TOR_SOURCE}"; \
    curl --fail --location --silent --show-error --remote-name "${TOR_SOURCE}.sha256sum"; \
    curl --fail --location --silent --show-error --remote-name "${TOR_SOURCE}.sha256sum.asc"; \
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys \
      2133BC600AB133E1D826D173FE43009C4607B1FB \
      514102454D0A87DB0767A1EBBE6A0531C18A9179 \
      B74417EDDF22AC9F9E90F49142E86A2A11F48D36; \
    gpg --batch --verify "tor-${TOR_VERSION}.tar.gz.sha256sum.asc" "tor-${TOR_VERSION}.tar.gz.sha256sum"; \
    echo "${TOR_SHA256}  tor-${TOR_VERSION}.tar.gz" | sha256sum -c -; \
    tar -xzf "tor-${TOR_VERSION}.tar.gz"; \
    cd "tor-${TOR_VERSION}"; \
    ./configure --prefix=/usr/local; \
    make -j"$(nproc)" src/app/tor; \
    mkdir -p /out/usr/local/bin /out/usr/local/share/tor; \
    install -m 0755 src/app/tor /out/usr/local/bin/tor; \
    install -m 0644 src/config/geoip src/config/geoip6 /out/usr/local/share/tor/

FROM alpine:3.22

ARG TOR_VERSION=0.4.9.11
LABEL org.opencontainers.image.version="${TOR_VERSION}"

RUN apk add --no-cache \
    bash \
    libevent \
    libseccomp \
    openssl \
    xz-libs \
    zstd-libs \
    zlib

RUN adduser -s /bin/bash -D -u 2000 tor
RUN mkdir -p /var/run/tor && chown -R tor:tor /var/run/tor && chmod 2700 /var/run/tor
RUN mkdir -p /home/tor/tor && chown -R tor:tor /home/tor/tor && chmod 2700 /home/tor/tor

COPY --from=builder /out/usr/local/ /usr/local/
COPY ./torrc /home/tor/tor/torrc

USER tor
