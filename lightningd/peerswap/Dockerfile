ARG BITCOIN_VER=31.1
ARG ELEMENTS_VER=23.3.3
ARG UV_VERSION=0.12.0
ARG CLN_VER=v25.12.1
ARG CLN_UPSTREAM_DIGEST=sha256:618eed33ba923cc459164bba38e8c554f97113f730a2f96e8423b18c0c515d9d
FROM blockstream/bitcoind:${BITCOIN_VER} AS bitcoind
FROM blockstream/elementsd:${ELEMENTS_VER} AS elementsd
FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv
FROM elementsproject/lightningd:${CLN_VER}@${CLN_UPSTREAM_DIGEST} AS cln_upstream
ARG CLN_VER
RUN test "$(/usr/local/bin/lightningd --version)" = "${CLN_VER}"
# https://github.com/docker-library/golang/blob/master/1.22/bookworm/Dockerfile
FROM golang:1.22.11-bookworm AS builder

COPY --from=uv /uv /uvx /bin/

WORKDIR /opt

RUN apt-get update
RUN apt-get install -y \
  autoconf automake build-essential git libtool libgmp-dev libsqlite3-dev libssl-dev \
  python3 net-tools zlib1g-dev libsodium-dev gettext jq lowdown \
  && uv pip install --system --break-system-packages \
    mako mrkd mistune==0.8.4 grpcio-tools

# Get CLN
ARG CLN_VER
ENV CLN_VER=$CLN_VER
RUN git clone https://github.com/ElementsProject/lightning.git --depth 1 -b ${CLN_VER} /opt/lightningd

# Build CLN
WORKDIR /opt/lightningd
RUN git submodule update --init --recursive --depth 1
RUN ./configure --prefix=/opt/lightning_install
RUN make -j "$(nproc)"
RUN make install

FROM golang:1.22.11-bookworm

COPY --from=uv /uv /uvx /bin/
ENV UV_CACHE_DIR=/opt/uv-cache
ENV UV_PYTHON_DOWNLOADS=never

# CLN deps
RUN apt-get update
RUN apt-get install -yq git bash autoconf automake build-essential libtool libgmp-dev libsqlite3-dev \
  python3 net-tools zlib1g-dev libsodium-dev gettext

# Copy CLN binaries from builder, bitcoind/elementsd from respective images
COPY --from=builder /opt/lightning_install /usr/local
COPY --from=bitcoind /usr/local/bin/* /usr/local/bin/
COPY --from=bitcoind /usr/local/lib/* /usr/local/lib/
COPY --from=bitcoind /usr/local/share/* /usr/local/share/
COPY --from=elementsd /usr/local/bin/* /usr/local/bin/
COPY --from=elementsd /usr/local/lib/* /usr/local/lib/
COPY --from=elementsd /usr/local/share/* /usr/local/share/

# Install plugin dependencies (rebalance, summary, and Prometheus use inline uv metadata)
ARG PLUGIN_PATH=/opt/plugins
ARG RAW_GH_PLUGINS=https://raw.githubusercontent.com/lightningd/plugins/c0b768f3ed3c88d5119442299f159267b5fc09ba

RUN apt-get update
RUN apt-get install -yq wget make gcc libffi-dev python3-dev python3-gdbm
# Paytest is archived and has no inline uv metadata; match its pyln packages to CLN.
RUN uv pip install --system --break-system-packages \
  pyln-client==25.5 pyln-proto==25.5 pyln-bolt7

# Add custom plugins (rebalance, summary, prometheus, paytest)
RUN mkdir -p $PLUGIN_PATH \
  && wget -q -O $PLUGIN_PATH/rebalance.py $RAW_GH_PLUGINS/rebalance/rebalance.py \
  && wget -q -O $PLUGIN_PATH/summary.py $RAW_GH_PLUGINS/summary/summary.py \
  && wget -q -O $PLUGIN_PATH/prometheus.py $RAW_GH_PLUGINS/prometheus/prometheus.py \
  && wget -q -O $PLUGIN_PATH/paytest.py $RAW_GH_PLUGINS/archived/paytest/paytest.py \
  && chmod a+x $PLUGIN_PATH/* \
  && wget -q -O $PLUGIN_PATH/summary_avail.py $RAW_GH_PLUGINS/summary/summary_avail.py \
  && wget -q -O $PLUGIN_PATH/clnutils.py $RAW_GH_PLUGINS/rebalance/clnutils.py \
  && uv lock --script $PLUGIN_PATH/rebalance.py \
  && uv lock --script $PLUGIN_PATH/summary.py \
  && uv lock --script $PLUGIN_PATH/prometheus.py \
  && uv run --script $PLUGIN_PATH/rebalance.py </dev/null \
  && uv run --script $PLUGIN_PATH/summary.py </dev/null \
  && uv run --script $PLUGIN_PATH/prometheus.py </dev/null

# Add peerswap
ARG PEERSWAP_VER=v5.0.1
ENV PEERSWAP_VER=${PEERSWAP_VER}
RUN git clone https://github.com/ElementsProject/peerswap.git -n $PLUGIN_PATH/ps \
  && cd $PLUGIN_PATH/ps \
  # allows to fetch PRs
  && git config --local --add remote.origin.fetch '+refs/pull/*/head:refs/remotes/origin/pr/*' \
  && git fetch \
  && git checkout ${PEERSWAP_VER} \
  && make cln-release

# CLNRest is a Rust plugin and is absent from this image's local CLN build.
# Install the matching upstream binary in the configured custom plugin directory.
COPY --from=cln_upstream --chmod=0755 \
  /usr/local/libexec/c-lightning/plugins/clnrest \
  /opt/plugins/clnrest

ENTRYPOINT ["lightningd"]
CMD ["--help"]
