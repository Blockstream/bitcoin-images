ARG BITCOIN_VER=27.0
ARG ELEMENTS_VER=22.1.1
FROM blockstream/bitcoind:${BITCOIN_VER} AS bitcoind
FROM blockstream/elementsd:${ELEMENTS_VER} AS elementsd
# https://github.com/docker-library/golang/blob/master/1.22/bullseye/Dockerfile
FROM golang:1.22.11-bullseye AS builder

WORKDIR /opt

RUN apt-get update
RUN apt-get install -y \
  autoconf automake build-essential git libtool libgmp-dev libsqlite3-dev \
  python3 python3-pip net-tools zlib1g-dev libsodium-dev gettext jq \
  && pip3 install --upgrade pip mako mrkd mistune==0.8.4 grpcio-tools

# Get CLN
ARG CLN_VER=v24.08.2
ENV CLN_VER=$CLN_VER
RUN git clone https://github.com/ElementsProject/lightning.git --depth 5 -b ${CLN_VER} /opt/lightningd

# Build CLN
WORKDIR /opt/lightningd
RUN git submodule update --init --recursive --depth 5
RUN ./configure --prefix=/opt/lightning_install
RUN make -j 32 || sleep 9999
RUN make install

FROM golang:1.22.11-bullseye

# CLN deps
RUN apt-get update
RUN apt-get install -yq git bash autoconf automake build-essential libtool libgmp-dev libsqlite3-dev \
  python3 python3-pip net-tools zlib1g-dev libsodium-dev gettext 

# Copy CLN binaries from builder, bitcoind/elementsd from respective images
COPY --from=builder /opt/lightning_install /usr/local
COPY --from=bitcoind /usr/local/bin/* /usr/local/bin/
COPY --from=bitcoind /usr/local/lib/* /usr/local/lib/
COPY --from=bitcoind /usr/local/share/* /usr/local/share/
COPY --from=elementsd /usr/local/bin/* /usr/local/bin/
COPY --from=elementsd /usr/local/lib/* /usr/local/lib/
COPY --from=elementsd /usr/local/share/* /usr/local/share/

# Install plugin dependencies
ARG PLUGIN_PATH=/opt/plugins
ARG RAW_GH_PLUGINS=https://raw.githubusercontent.com/lightningd/plugins/3fc4ece1ba42bf69b4f8ab6f5683decada0502b2

RUN apt-get update
RUN apt-get install -yq wget make gcc libffi-dev python3-dev python3-gdbm
RUN pip3 install --upgrade pip wheel
# Not installing paytest's deps since they should be covered by other packages'
## and its pyln-client/proto version requirement was a bit too old (0.9.2 up to 0.10.0)
RUN pip3 install -r $RAW_GH_PLUGINS/rebalance/requirements.txt \
                 -r $RAW_GH_PLUGINS/summary/requirements.txt \
                 prometheus-client==0.6.0 \
                 pyln-bolt7 \
                 pyln-proto

# Add custom plugins (rebalance, summary, prometheus, paytest)
RUN mkdir -p $PLUGIN_PATH \  
  && wget -q -O $PLUGIN_PATH/rebalance.py $RAW_GH_PLUGINS/rebalance/rebalance.py \
  && wget -q -O $PLUGIN_PATH/summary.py $RAW_GH_PLUGINS/summary/summary.py \
  && wget -q -O $PLUGIN_PATH/prometheus.py $RAW_GH_PLUGINS/archived/prometheus/prometheus.py \
  && wget -q -O $PLUGIN_PATH/paytest.py $RAW_GH_PLUGINS/archived/paytest/paytest.py \
  && chmod a+x $PLUGIN_PATH/* \
  && wget -q -O $PLUGIN_PATH/summary_avail.py $RAW_GH_PLUGINS/summary/summary_avail.py \
  && wget -q -O $PLUGIN_PATH/clnutils.py $RAW_GH_PLUGINS/rebalance/clnutils.py

# Add peerswap
ARG PEERSWAP_VER=5935fb4656307a87cafde2513d54deec1c26f8f2
ENV PEERSWAP_VER=${PEERSWAP_VER}
RUN git clone https://github.com/ElementsProject/peerswap.git -n $PLUGIN_PATH/ps \
  && cd $PLUGIN_PATH/ps \
  # allows to fetch PRs
  && git config --local --add remote.origin.fetch '+refs/pull/*/head:refs/remotes/origin/pr/*' \
  && git fetch \
  && git checkout ${PEERSWAP_VER} \
  && make cln-release

ENTRYPOINT ["lightningd"]
CMD ["--help"]
