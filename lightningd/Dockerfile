ARG BITCOIN_VER=27.2
FROM blockstream/bitcoind:${BITCOIN_VER} AS builder

# Get CLN
ARG CLN_VER=v25.05
ENV CLN_VER=${CLN_VER}
RUN apt update \
  && apt install -qfy jq autoconf automake build-essential git libtool libsqlite3-dev libffi-dev \
                       python3 python3-pip net-tools zlib1g-dev libsodium-dev gettext protobuf-compiler libpq-dev
RUN pip3 install mako --break-system-packages \
 && pip3 install grpcio-tools --break-system-packages
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
RUN echo 'source $HOME/.cargo/env' >> $HOME/.bashrc
RUN git clone https://github.com/ElementsProject/lightning.git --depth 5 -b ${CLN_VER} /opt/lightningd

# Build CLN
WORKDIR /opt/lightningd
RUN git submodule update --init --recursive --depth 5
RUN ./configure --prefix=/opt/lightning_install
RUN make -j$(nproc)
RUN make install

# Final image
FROM debian:bookworm-slim

# CLN deps
RUN apt update \
 && apt install -qfy jq libtool libsqlite3-dev libffi-dev \
  python3 python3-pip net-tools zlib1g-dev libsodium-dev gettext wget libpq-dev

# Install plugin dependencies (Prom's managed inline with uv)
ARG PLUGIN_PATH=/opt/plugins
ARG RAW_GH_PLUGINS=https://raw.githubusercontent.com/lightningd/plugins/master
RUN mkdir -p ${PLUGIN_PATH}

RUN pip3 install --break-system-packages --upgrade pip wheel uv
RUN pip3 install --break-system-packages -r $RAW_GH_PLUGINS/summary/requirements.txt

# Add custom plugins (prometheus, summary)
RUN wget -q -O $PLUGIN_PATH/prometheus.py $RAW_GH_PLUGINS/prometheus/prometheus.py
RUN wget -q -O $PLUGIN_PATH/summary.py $RAW_GH_PLUGINS/summary/summary.py
RUN chmod a+x $PLUGIN_PATH/*
RUN wget -q -O $PLUGIN_PATH/summary_avail.py $RAW_GH_PLUGINS/summary/summary_avail.py

# Copy binaries from builder
COPY --from=builder /opt/lightning_install /usr/local
COPY --from=builder /usr/local/bin/* /usr/local/bin/
COPY --from=builder /usr/local/lib/* /usr/local/lib/
COPY --from=builder /usr/local/share/* /usr/local/share/

RUN apt clean && apt autoclean

ENTRYPOINT ["lightningd"]
CMD ["--help"]
