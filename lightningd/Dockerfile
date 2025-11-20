ARG VER=stable
FROM elementsproject/lightningd:${VER}

# Install Python and required system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 python3-pip python3-venv wget
# Prepare plugin directory
ARG PLUGIN_PATH=/opt/plugins
ARG RAW_GH_PLUGINS=https://raw.githubusercontent.com/lightningd/plugins/master
RUN mkdir -p ${PLUGIN_PATH}

# Install plugin Python dependencies
RUN pip3 install --break-system-packages --upgrade pip wheel uv
RUN pip3 install --break-system-packages -r $RAW_GH_PLUGINS/summary/requirements.txt

# Add custom plugins (prometheus, summary)
# Download plugins
RUN wget -q -O $PLUGIN_PATH/prometheus.py $RAW_GH_PLUGINS/prometheus/prometheus.py
RUN wget -q -O $PLUGIN_PATH/summary.py $RAW_GH_PLUGINS/summary/summary.py
# This chmod is intentionally set above summary_avail.py since this is not a plugin.
# lightningd picks up everything that's an executable as a plugin.
RUN chmod a+x $PLUGIN_PATH/*
RUN wget -q -O $PLUGIN_PATH/summary_avail.py $RAW_GH_PLUGINS/summary/summary_avail.py

# Final cleanup: remove temporary files to reduce image size
RUN rm -rf /var/lib/apt/lists/* /tmp/requirements.txt