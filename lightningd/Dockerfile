ARG VER=latest
FROM elementsproject/lightningd:${VER}

# Install Python and required system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 python3-pip python3-venv wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Prepare plugin directory
ARG PLUGIN_PATH=/opt/plugins
ARG RAW_GH_PLUGINS=https://raw.githubusercontent.com/lightningd/plugins/master
RUN mkdir -p ${PLUGIN_PATH}

# Install plugin Python dependencies
RUN pip3 install --break-system-packages --upgrade pip wheel uv
RUN wget -q -O /tmp/requirements.txt $RAW_GH_PLUGINS/summary/requirements.txt && \
    pip3 install --break-system-packages -r /tmp/requirements.txt

# Download plugins
RUN wget -q -O $PLUGIN_PATH/prometheus.py $RAW_GH_PLUGINS/prometheus/prometheus.py
RUN wget -q -O $PLUGIN_PATH/summary.py $RAW_GH_PLUGINS/summary/summary.py
RUN wget -q -O $PLUGIN_PATH/summary_avail.py $RAW_GH_PLUGINS/summary/summary_avail.py
RUN chmod a+x $PLUGIN_PATH/*

# Cleanup (optional)
RUN rm -rf /var/lib/apt/lists/* /tmp/requirements.txt