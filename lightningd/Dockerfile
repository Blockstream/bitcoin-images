FROM alpine:3.17 AS builder

# Download bitcoin binaries
ENV WLADIMIRVDL_PGP_KEY=https://raw.githubusercontent.com/bitcoin-core/guix.sigs/main/builder-keys/laanwj.gpg
ENV ACHOW_PGP_KEY=https://raw.githubusercontent.com/bitcoin-core/guix.sigs/main/builder-keys/achow101.gpg
ENV BITCOIN_VERSION=24.1

RUN apk add --no-cache --upgrade ca-certificates alpine-sdk autoconf automake git libtool \
  gmp-dev sqlite-dev py3-pip net-tools zlib-dev libsodium gettext \
  build-base coreutils wget gnupg coreutils swig postgresql-dev \
  && pip3 install mako mrkd mistune==0.8.4

# Get bitcoin
RUN wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz \
  && wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS.asc \
  && wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS

RUN curl -s ${WLADIMIRVDL_PGP_KEY} | gpg --import \
  && curl -s ${ACHOW_PGP_KEY} | gpg --import \
  && csplit -ksz SHA256SUMS.asc  /-----BEGIN/ '{*}' \
  && for i in xx*; do gpg --verify $i SHA256SUMS && break; done \
  && grep bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz SHA256SUMS | sha256sum -c
RUN mkdir /opt/bitcoin \
  && tar xzvf bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz --strip-components=1 -C /opt/bitcoin

# Get CLN
ARG CLN_VERSION=v23.08
ENV CLN_VERSION=$CLN_VERSION
RUN git clone https://github.com/ElementsProject/lightning.git --depth 20 -b ${CLN_VERSION} /opt/lightningd

# Build CLN
WORKDIR /opt/lightningd
RUN git submodule update --init --recursive --depth 20
RUN ./configure --prefix=/opt/lightning_install
# temporary fix for alpine builds
RUN rm -r cli/test/*.c
RUN make -j 32
RUN make install

FROM alpine:3.17

# CLN deps
RUN apk add --no-cache ca-certificates gmp libgcc libsodium sqlite-libs zlib \
 inotify-tools socat bash gnupg py3-pip postgresql-libs

# # Add GNU Lib C
ENV GLIBC_VERSION=2.33-r0
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk

RUN apk update \
  # context for --force-overwrite https://github.com/sgerrand/alpine-pkg-glibc/issues/185
  && apk --no-cache add --force-overwrite glibc-${GLIBC_VERSION}.apk glibc-bin-${GLIBC_VERSION}.apk \
  && rm -f glibc-*

# Copy binaries from builder
COPY --from=builder /opt/lightning_install /usr/local
COPY --from=builder /opt/bitcoin/bin/* /usr/local/bin/
COPY --from=builder /opt/bitcoin/lib/* /usr/local/lib/
COPY --from=builder /opt/bitcoin/share/* /usr/local/share/

# Install plugin dependencies
ARG PLUGIN_PATH=/opt/plugins
ARG RAW_GH_PLUGINS=https://raw.githubusercontent.com/lightningd/plugins/master

RUN apk add --no-cache --virtual deps wget git make gcc musl-dev libffi-dev python3-dev
RUN pip3 install --upgrade pip wheel
RUN pip3 install -r $RAW_GH_PLUGINS/summary/requirements.txt \
  prometheus-client==0.6.0

# Add custom plugins (prometheus, summary)
RUN mkdir -p $PLUGIN_PATH \
  && wget -q -O $PLUGIN_PATH/prometheus.py $RAW_GH_PLUGINS/prometheus/prometheus.py \
  && wget -q -O $PLUGIN_PATH/summary.py $RAW_GH_PLUGINS/summary/summary.py \
  && chmod a+x $PLUGIN_PATH/* \
  && wget -q -O $PLUGIN_PATH/summary_avail.py $RAW_GH_PLUGINS/summary/summary_avail.py

RUN apk --purge del deps

ENTRYPOINT ["lightningd"]
CMD ["--help"]