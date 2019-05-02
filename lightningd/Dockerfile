FROM alpine@sha256:28ef97b8686a0b5399129e9b763d5b7e5ff03576aa5580d6f4182a49c5fe1913 AS builder

RUN apk add --no-cache ca-certificates autoconf automake \
  build-base libressl libtool gmp-dev  python python-dev \
  python3 sqlite-dev wget git file gnupg swig zlib-dev

# Download bitcoin binaries
ENV BITCOIN_VERSION=0.18.0
ENV BITCOIN_DIR_VERSION=0.18.0
ENV BITCOIN_PGP_KEY=01EA5486DE18A882D4C2684590C8019E36C2E964

WORKDIR /opt/bitcoin
RUN wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS.asc \
 && wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz

RUN gpg --keyserver keyserver.ubuntu.com --recv-keys ${BITCOIN_PGP_KEY} \
  && gpg --verify SHA256SUMS.asc \
  && grep bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz SHA256SUMS.asc | sha256sum -c
RUN tar xzvf bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz

# Build lightningd
ENV LIGHTNINGD_VERSION=v0.7.0
RUN git clone https://github.com/ElementsProject/lightning.git /opt/lightningd && \
  cd /opt/lightningd && \
  git checkout ${LIGHTNINGD_VERSION} && \
  ./configure && \
  make && make install

FROM alpine@sha256:28ef97b8686a0b5399129e9b763d5b7e5ff03576aa5580d6f4182a49c5fe1913

ARG BITCOIN_DIR_VERSION=0.18.0

RUN apk add --no-cache gmp-dev sqlite-dev inotify-tools socat bash \
  zlib-dev wget ca-certificates gnupg

# Add GNU Lib C
ENV GLIBC_VERSION=2.28-r0
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk

RUN apk update \
  && apk --no-cache add glibc-${GLIBC_VERSION}.apk \
 	&& apk --no-cache add glibc-bin-${GLIBC_VERSION}.apk \
  && rm -f glibc-*

COPY --from=builder /opt/lightningd/cli/lightning-cli /usr/local/bin
COPY --from=builder /opt/lightningd/lightningd/lightning* /usr/local/bin/
COPY --from=builder /opt/lightningd/plugins/* /usr/local/bin/plugins/
COPY --from=builder /opt/bitcoin/bitcoin-${BITCOIN_DIR_VERSION}/bin/* /usr/local/bin/
