# 3.14.4
FROM alpine@sha256:a8c98a08ab965e9a033a8266e519519a7b615c01d22c6790a47d5853716a8726 AS builder

# Download bitcoin binaries
ENV WLADIMIRVDL_PGP_KEY=71A3B16735405025D447E8F274810B012346C9A6
ENV ACHOW_PGP_KEY=152812300785C96444D3334D17565732E08E5E41
ENV BITCOIN_VERSION=22.0

RUN apk add --no-cache --upgrade ca-certificates autoconf automake git libtool \
  gmp-dev sqlite-dev py3-pip net-tools zlib-dev libsodium gettext \
  build-base coreutils wget gnupg coreutils swig postgresql-dev \
  && pip3 install mako mrkd mistune==0.8.4

# Get bitcoin
RUN wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz \
  && wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS.asc \
  && wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS

RUN gpg --keyserver hkps://keys.openpgp.org --recv-keys ${WLADIMIRVDL_PGP_KEY} ${ACHOW_PGP_KEY} \
  && csplit -ksz SHA256SUMS.asc  /-----BEGIN/ '{*}' \
  && for i in xx*; do gpg --verify $i SHA256SUMS && break; done \
  && grep bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz SHA256SUMS | sha256sum -c
RUN mkdir /opt/bitcoin \
  && tar xzvf bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz --strip-components=1 -C /opt/bitcoin

# Get c-lightning
ARG CLN_VERSION=v0.12.1
ENV CLN_VERSION=$CLN_VERSION
RUN git clone https://github.com/ElementsProject/lightning.git --depth 20 -b ${CLN_VERSION} /opt/lightningd

# Build c-lightning
WORKDIR /opt/lightningd
RUN git submodule update --init --recursive --depth 20
RUN ./configure --prefix=/opt/lightning_install
# temporary fix for alpine builds
RUN rm -r cli/test/*.c
RUN make -j 32
RUN make install

FROM alpine@sha256:85e16a753e459ea44a8aa1dfc1cb8b625f9c487b00ea686384a96923a3691f4e

# C-Lightning deps
RUN apk add --no-cache gmp-dev inotify-tools socat bash \
  zlib-dev ca-certificates gnupg py3-pip sqlite-libs postgresql-libs

# Add GNU Lib C
ENV GLIBC_VERSION=2.33-r0
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