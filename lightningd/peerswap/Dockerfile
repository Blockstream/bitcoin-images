# Actual version values are supplied by build-and-push-to-dockerhub.sh.
# These sentinels keep each FROM reference valid during static checks.
ARG BITCOIN_VER=build-arg-required
ARG ELEMENTS_VER=build-arg-required
ARG GO_VERSION=build-arg-required
ARG RUST_VERSION=build-arg-required
ARG UV_VERSION=build-arg-required
ARG CLN_VER
FROM blockstream/bitcoind:${BITCOIN_VER} AS bitcoind
FROM blockstream/elementsd:${ELEMENTS_VER} AS elementsd
FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv
FROM rust:${RUST_VERSION}-bookworm AS builder

COPY --from=uv /uv /uvx /bin/
ENV RUST_PROFILE=release

WORKDIR /opt

RUN apt-get update
RUN apt-get install -y \
  autoconf automake bison build-essential flex git libtool libffi-dev libgmp-dev \
  libicu-dev libsqlite3-dev libssl-dev pkg-config protobuf-compiler \
  python3 python3-dev net-tools zlib1g-dev libsodium-dev gettext jq lowdown \
  && uv pip install --system --break-system-packages \
    mako mrkd mistune==0.8.4 grpcio-tools

# Get CLN
ARG CLN_VER
ENV CLN_VER=$CLN_VER
RUN git clone https://github.com/ElementsProject/lightning.git --depth 1 -b ${CLN_VER} /opt/lightningd

# Build CLN
WORKDIR /opt/lightningd
RUN git submodule update --init --recursive --depth 1
RUN PG_CONFIG= ./configure --prefix=/opt/lightning_install --enable-rust
ENV VERSION=$CLN_VER
RUN make -j "$(nproc)"
RUN make install
RUN test -x /opt/lightning_install/libexec/c-lightning/plugins/clnrest

FROM golang:${GO_VERSION}-trixie

COPY --from=uv /uv /uvx /bin/
ENV UV_CACHE_DIR=/opt/uv-cache
ENV UV_PYTHON_DOWNLOADS=never

# CLN deps
RUN apt-get update
RUN apt-get install -yq git bash autoconf automake build-essential libtool libgmp-dev libsqlite3-dev \
  python3 net-tools zlib1g-dev libsodium-dev gettext

# Copy CLN binaries, including the locally built CLNRest plugin, from builder;
# copy bitcoind/elementsd from their respective images.
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
ARG PYLN_VERSION

RUN apt-get update
RUN apt-get install -yq wget make gcc libffi-dev python3-dev python3-gdbm
# Paytest is archived and has no inline uv metadata; match its pyln packages to CLN.
RUN uv pip install --system --break-system-packages \
  pyln-client==${PYLN_VERSION} pyln-proto==${PYLN_VERSION} pyln-bolt7

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
ARG PEERSWAP_VER
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
