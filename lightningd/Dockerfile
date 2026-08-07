ARG VER=stable
ARG UV_VERSION=0.12.0
FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv
FROM elementsproject/lightningd:${VER}

COPY --from=uv /uv /uvx /bin/
ENV UV_CACHE_DIR=/opt/uv-cache
ENV UV_PYTHON_DOWNLOADS=never

# Install Python and required system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates python3 wget
# Prepare plugin directory
ARG PLUGIN_PATH=/opt/plugins
ARG RAW_GH_PLUGINS=https://raw.githubusercontent.com/lightningd/plugins/c0b768f3ed3c88d5119442299f159267b5fc09ba
RUN mkdir -p ${PLUGIN_PATH}

# Add custom plugins (prometheus and summary) and install their inline uv dependencies.
# summary_avail.py is a helper, not a plugin, and must not be executable.
RUN wget -q -O $PLUGIN_PATH/prometheus.py $RAW_GH_PLUGINS/prometheus/prometheus.py \
    && wget -q -O $PLUGIN_PATH/summary.py $RAW_GH_PLUGINS/summary/summary.py \
    && chmod a+x $PLUGIN_PATH/* \
    && wget -q -O $PLUGIN_PATH/summary_avail.py $RAW_GH_PLUGINS/summary/summary_avail.py \
    && uv lock --script $PLUGIN_PATH/prometheus.py \
    && uv lock --script $PLUGIN_PATH/summary.py \
    && uv run --script $PLUGIN_PATH/prometheus.py </dev/null \
    && uv run --script $PLUGIN_PATH/summary.py </dev/null

# Final cleanup: remove temporary files to reduce image size
RUN rm -rf /var/lib/apt/lists/*
