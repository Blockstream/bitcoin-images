ARG BITCOIN_VERSION=27.0
FROM blockstream/bitcoind:${BITCOIN_VERSION} AS builder

# Get CLN
ARG CLN_VERSION
ENV CLN_VERSION=$CLN_VERSION
RUN apt update \
  && apt install -qfy jq autoconf automake build-essential git libtool libsqlite3-dev libffi-dev \
                       python3 python3-pip net-tools zlib1g-dev libsodium-dev gettext protobuf-compiler
RUN pip3 install mako --break-system-packages \
 && pip3 install grpcio-tools --break-system-packages
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
RUN echo 'source $HOME/.cargo/env' >> $HOME/.bashrc
RUN git clone https://github.com/ElementsProject/lightning.git --depth 5 -b ${CLN_VERSION} /opt/lightningd

# Build CLN
WORKDIR /opt/lightningd
RUN git submodule update --init --recursive --depth 5
RUN ./configure --prefix=/opt/lightning_install
RUN make -j$(nproc)
RUN make install

# Install plugin dependencies
ARG PLUGIN_PATH=/opt/plugins
ARG RAW_GH_PLUGINS=https://raw.githubusercontent.com/lightningd/plugins/master
RUN pip3 install --upgrade pip wheel --break-system-packages
RUN pip3 install -r $RAW_GH_PLUGINS/summary/requirements.txt \
  prometheus-client==0.6.0 --break-system-packages

# Add custom plugins (prometheus, summary)
RUN apt install -qfy wget
RUN mkdir -p $PLUGIN_PATH
RUN wget -q -O $PLUGIN_PATH/prometheus.py $RAW_GH_PLUGINS/archived/prometheus/prometheus.py
RUN wget -q -O $PLUGIN_PATH/summary.py $RAW_GH_PLUGINS/summary/summary.py
RUN chmod a+x $PLUGIN_PATH/*
RUN wget -q -O $PLUGIN_PATH/summary_avail.py $RAW_GH_PLUGINS/summary/summary_avail.py

# Final image
FROM debian:bookworm-slim

# CLN deps
RUN apt update \
 && apt install -qfy jq libtool libsqlite3-dev libffi-dev \
  python3 python3-pip net-tools zlib1g-dev libsodium-dev gettext

# Copy binaries from builder
COPY --from=builder /opt/lightning_install /usr/local
COPY --from=builder /usr/local/bin/* /usr/local/bin/
COPY --from=builder /usr/local/lib/* /usr/local/lib/
COPY --from=builder /usr/local/share/* /usr/local/share/
COPY --from=builder /opt/plugins /opt/plugins

RUN apt clean && apt autoclean

ENTRYPOINT ["lightningd"]
CMD ["--help"]
