FROM alpine@sha256:a15790640a6690aa1730c38cf0a440e2aa44aaca9b0e8931a9f2b0d7cc90fd65 AS builder

# Download bitcoin binaries
ENV BITCOIN_VERSION=0.21.0
ENV BITCOIN_PGP_KEY=01EA5486DE18A882D4C2684590C8019E36C2E964

RUN apk add --no-cache --upgrade ca-certificates autoconf automake \
  build-base libressl libtool gmp-dev py3-pip python2 \
  sqlite-dev wget git file gnupg swig zlib-dev gettext \
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
ENV LIGHTNINGD_VERSION=v0.9.3
RUN git clone https://github.com/ElementsProject/lightning.git -b ${LIGHTNINGD_VERSION} /opt/lightningd 

# Build c-lightning
WORKDIR /opt/lightningd
RUN ./configure --prefix=/opt/lightning_install
RUN make 
RUN make install

FROM alpine@sha256:a15790640a6690aa1730c38cf0a440e2aa44aaca9b0e8931a9f2b0d7cc90fd65

RUN apk add --no-cache gmp-dev sqlite-dev inotify-tools socat bash \
  zlib-dev wget ca-certificates gnupg py3-pip

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
RUN pip3 install wheel
RUN pip3 install -r https://raw.githubusercontent.com/lightningd/plugins/master/summary/requirements.txt \
  prometheus-client==0.6.0

ARG PLUGIN_PATH=/usr/local/libexec/c-lightning/plugins

# Add custom plugins (prometheus, summary)
RUN wget -q -O $PLUGIN_PATH/prometheus.py https://raw.githubusercontent.com/lightningd/plugins/master/prometheus/prometheus.py \
  && wget -q -O $PLUGIN_PATH/summary.py https://raw.githubusercontent.com/lightningd/plugins/master/summary/summary.py \
  && chmod a+x $PLUGIN_PATH/* \
  && wget -q -O $PLUGIN_PATH/summary_avail.py https://raw.githubusercontent.com/lightningd/plugins/master/summary/summary_avail.py 
