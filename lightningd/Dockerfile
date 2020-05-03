FROM alpine@sha256:769fddc7cc2f0a1c35abb2f91432e8beecf83916c421420e6a6da9f8975464b6 AS builder

# Download bitcoin binaries
ENV BITCOIN_VERSION=0.19.1
ENV BITCOIN_PGP_KEY=01EA5486DE18A882D4C2684590C8019E36C2E964

WORKDIR /opt/bitcoin
RUN wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz \
  && wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS.asc

RUN apk add --no-cache ca-certificates autoconf automake \
  build-base libressl libtool gmp-dev  python python-dev \
  python3 sqlite-dev wget git file gnupg swig zlib-dev gettext \
  && pip3 install mako

RUN gpg --keyserver keyserver.ubuntu.com --recv-keys ${BITCOIN_PGP_KEY} \
  && gpg --verify SHA256SUMS.asc \
  && grep bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz SHA256SUMS.asc | sha256sum -c
RUN tar xzvf bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz --strip-components=1 -C /opt/bitcoin

# Build lightningd
ENV LIGHTNINGD_VERSION=v0.8.2
RUN git clone https://github.com/ElementsProject/lightning.git -b ${LIGHTNINGD_VERSION} /opt/lightningd \
  && cd /opt/lightningd \
  && ./configure \
  && make && make install

# Add custom plugins
RUN wget -q -O /opt/lightningd/plugins/prometheus.py https://raw.githubusercontent.com/lightningd/plugins/master/prometheus/prometheus.py \
  && chmod a+x /opt/lightningd/plugins/prometheus.py

FROM alpine@sha256:769fddc7cc2f0a1c35abb2f91432e8beecf83916c421420e6a6da9f8975464b6

RUN apk add --no-cache gmp-dev sqlite-dev inotify-tools socat bash \
  zlib-dev wget ca-certificates gnupg python3

# Add GNU Lib C
ENV GLIBC_VERSION=2.28-r0
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk

RUN apk update \
  && apk --no-cache add glibc-${GLIBC_VERSION}.apk \
 	&& apk --no-cache add glibc-bin-${GLIBC_VERSION}.apk \
  && rm -f glibc-*

# install plugin dependencies
RUN pip3 install -r https://raw.githubusercontent.com/lightningd/plugins/master/prometheus/requirements.txt

COPY --from=builder /opt/lightningd/cli/lightning-cli /usr/local/bin
COPY --from=builder /opt/lightningd/lightningd/lightning* /usr/local/bin/
COPY --from=builder /opt/lightningd/plugins/* /usr/local/bin/plugins/
COPY --from=builder /opt/bitcoin/bin/* /usr/local/bin/
