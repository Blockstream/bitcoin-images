# 3.13.6
FROM alpine@sha256:e15947432b813e8ffa90165da919953e2ce850bef511a0ad1287d7cb86de84b5 AS builder

# Download bitcoin binaries
ENV BITCOIN_VERSION=0.21.1
ENV BITCOIN_PGP_KEY=01EA5486DE18A882D4C2684590C8019E36C2E964

RUN apk add --no-cache --upgrade ca-certificates autoconf automake \
  build-base libressl libtool gmp-dev py3-pip python2 \
  sqlite-dev wget git file gnupg swig zlib-dev gettext postgresql-dev \
  && pip3 install mako

# Get bitcoin
WORKDIR /opt/bitcoin
RUN wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz \
  && wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS.asc
RUN gpg --keyserver keyserver.ubuntu.com --recv-keys ${BITCOIN_PGP_KEY} \
  && gpg --verify SHA256SUMS.asc \
  && grep bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz SHA256SUMS.asc | sha256sum -c
RUN tar xzvf bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz --strip-components=1 -C /opt/bitcoin

# Get c-lightning
ARG CLN_VERSION=v23.08
ENV CLN_VERSION=$CLN_VERSION
RUN git clone https://github.com/ElementsProject/lightning.git -b ${CLN_VERSION} /opt/lightningd 

# Build c-lightning
WORKDIR /opt/lightningd
RUN git submodule update --init --recursive --depth 20
RUN ./configure --prefix=/opt/lightning_install
RUN make -j 32
RUN make install

FROM alpine@sha256:e15947432b813e8ffa90165da919953e2ce850bef511a0ad1287d7cb86de84b5

# C-Lightning deps
RUN apk add --no-cache gmp-dev inotify-tools socat bash \
  zlib-dev ca-certificates gnupg py3-pip sqlite-libs postgresql-libs

# Add GNU Lib C
ENV GLIBC_VERSION=2.28-r0
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk

RUN apk update \
  && apk --no-cache add glibc-${GLIBC_VERSION}.apk \
 	&& apk --no-cache add glibc-bin-${GLIBC_VERSION}.apk \
  && rm -f glibc-*

# Copy binaries from builder
COPY --from=builder /opt/lightning_install /usr/local
COPY --from=builder /opt/bitcoin/bin/* /usr/local/bin/

# Install plugin dependencies
RUN apk add --no-cache --virtual deps wget 
RUN pip3 install --upgrade pip wheel
RUN pip3 install -r https://raw.githubusercontent.com/lightningd/plugins/3fc4ece1ba42bf69b4f8ab6f5683decada0502b2/summary/requirements.txt

ARG PLUGIN_PATH=/opt/plugins

# Add custom plugins (sauron, summary)
RUN mkdir -p $PLUGIN_PATH \  
  && wget -q -O $PLUGIN_PATH/sauron.py https://raw.githubusercontent.com/lightningd/plugins/3fc4ece1ba42bf69b4f8ab6f5683decada0502b2/sauron/sauron.py \
  && wget -q -O $PLUGIN_PATH/summary.py https://raw.githubusercontent.com/lightningd/plugins/3fc4ece1ba42bf69b4f8ab6f5683decada0502b2/summary/summary.py \
  && chmod a+x $PLUGIN_PATH/* \
  && wget -q -O $PLUGIN_PATH/art.py https://raw.githubusercontent.com/lightningd/plugins/3fc4ece1ba42bf69b4f8ab6f5683decada0502b2/sauron/art.py
RUN apk --purge del deps

ENTRYPOINT ["lightningd"]
CMD ["--help"]