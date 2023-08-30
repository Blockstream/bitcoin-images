# https://github.com/docker-library/golang/blob/master/1.20/buster/Dockerfile
FROM golang:1.20.4-buster AS builder

WORKDIR /opt

# Download bitcoin binaries
ENV WLADIMIRVDL_PGP_KEY=https://raw.githubusercontent.com/bitcoin-core/guix.sigs/main/builder-keys/laanwj.gpg
ENV ACHOW_PGP_KEY=https://raw.githubusercontent.com/bitcoin-core/guix.sigs/main/builder-keys/achow101.gpg
ENV BITCOIN_VERSION=24.1

RUN apt-get update
RUN apt-get install -y \
  autoconf automake build-essential git libtool libgmp-dev libsqlite3-dev \
  python3 python3-pip net-tools zlib1g-dev libsodium-dev gettext \
  && pip3 install --upgrade pip mako mrkd mistune==0.8.4

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
  && tar xzvf bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz --strip-components=1 -C /opt/bitcoin \
  && rm SHA256SUMS*

# Download elements binaries
ENV ELEMENTS_VERSION=22.1.1
ENV ELEMENTS_PGP_KEY="https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xbd0f3062f87842410b06a0432f656b0610604482"

RUN wget https://github.com/ElementsProject/elements/releases/download/elements-${ELEMENTS_VERSION}/elements-${ELEMENTS_VERSION}-x86_64-linux-gnu.tar.gz \
 && wget https://github.com/ElementsProject/elements/releases/download/elements-${ELEMENTS_VERSION}/SHA256SUMS.asc

RUN curl -s ${ELEMENTS_PGP_KEY} | gpg --import \
  && gpg --verify SHA256SUMS.asc \
  && grep elements-${ELEMENTS_VERSION}-x86_64-linux-gnu.tar.gz SHA256SUMS.asc | sha256sum -c
RUN mkdir /opt/elements \
  && tar xzvf elements-${ELEMENTS_VERSION}-x86_64-linux-gnu.tar.gz --strip-components=1 -C /opt/elements

# Get c-lightning
ARG CLN_VERSION=v23.08
ENV CLN_VERSION=$CLN_VERSION
RUN git clone https://github.com/ElementsProject/lightning.git --depth 5 -b ${CLN_VERSION} /opt/lightningd

# Build c-lightning
WORKDIR /opt/lightningd
RUN git submodule update --init --recursive --depth 20
RUN ./configure --prefix=/opt/lightning_install
RUN make -j 32 || sleep 9999
RUN make install

FROM golang:1.20.4-buster

# C-Lightning deps
RUN apt-get update
RUN apt-get install -yq git bash autoconf automake build-essential libtool libgmp-dev libsqlite3-dev \
  python3 python3-pip net-tools zlib1g-dev libsodium-dev gettext 

# Copy binaries from builder
COPY --from=builder /opt/lightning_install /usr/local
COPY --from=builder /opt/bitcoin/bin/* /usr/local/bin/
COPY --from=builder /opt/bitcoin/lib/* /usr/local/lib/
COPY --from=builder /opt/bitcoin/share/* /usr/local/share/
COPY --from=builder /opt/elements/bin/* /usr/local/bin/
COPY --from=builder /opt/elements/lib/* /usr/local/lib/
COPY --from=builder /opt/elements/share/* /usr/local/share/

# Install plugin dependencies
ARG PLUGIN_PATH=/opt/plugins
ARG RAW_GH_PLUGINS=https://raw.githubusercontent.com/lightningd/plugins/master

RUN apt-get update
RUN apt-get install -yq wget make gcc libffi-dev python3-dev python3-gdbm
RUN pip3 install --upgrade pip wheel
RUN pip3 install -r $RAW_GH_PLUGINS/rebalance/requirements.txt \
                 -r $RAW_GH_PLUGINS/summary/requirements.txt \
                 prometheus-client==0.6.0 \
                 pyln-bolt7 \
                 pyln-proto

# Add custom plugins (rebalance, summary, prometheus, paytest)
RUN mkdir -p $PLUGIN_PATH \
  && wget -q -O $PLUGIN_PATH/rebalance.py $RAW_GH_PLUGINS/rebalance/rebalance.py \
  && wget -q -O $PLUGIN_PATH/summary.py $RAW_GH_PLUGINS/summary/summary.py \
  && wget -q -O $PLUGIN_PATH/prometheus.py $RAW_GH_PLUGINS/prometheus/prometheus.py \
  && wget -q -O $PLUGIN_PATH/paytest.py $RAW_GH_PLUGINS/paytest/paytest.py \
  && chmod a+x $PLUGIN_PATH/* \
  && wget -q -O $PLUGIN_PATH/summary_avail.py $RAW_GH_PLUGINS/summary/summary_avail.py \
  && wget -q -O $PLUGIN_PATH/clnutils.py $RAW_GH_PLUGINS/rebalance/clnutils.py

# Add peerswap
ARG PEERSWAP_COMMIT=19eeea491fe39cad78302096b6b2bd922af61be8
ENV PEERSWAP_COMMIT=$PEERSWAP_COMMIT
RUN git clone https://github.com/ElementsProject/peerswap.git -n $PLUGIN_PATH/ps \
  && cd $PLUGIN_PATH/ps \
  # allows to fetch PRs
  && git config --local --add remote.origin.fetch '+refs/pull/*/head:refs/remotes/origin/pr/*' \
  && git fetch \
  && git checkout $PEERSWAP_COMMIT \
  && make cln-release

ENTRYPOINT ["lightningd"]
CMD ["--help"]
