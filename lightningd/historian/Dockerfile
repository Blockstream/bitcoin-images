ARG CLN_VER=latest
FROM blockstream/lightningd:${CLN_VER}

# Install plugin dependencies
RUN apt install -qfy jq autoconf automake build-essential git libtool libsqlite3-dev libffi-dev \
    python3 python3-pip net-tools zlib1g-dev libsodium-dev gettext wget unzip pkg-config
RUN pip3 install poetry --break-system-packages

ENV PLUGIN_PATH=/opt/plugins

# Add custom plugins (connection pool, historian)
COPY connectionpool.py $PLUGIN_PATH/connectionpool.py
RUN mkdir -p $PLUGIN_PATH/historian/cli \
  && wget -q https://github.com/lightningd/plugins/archive/master.zip \
  && unzip -qqj master.zip "plugins-master/archived/historian/cli/*" -d "${PLUGIN_PATH}/historian/cli" \
  && unzip -qqj master.zip "plugins-master/archived/historian/*" -x "plugins-master/archived/historian/cli/*" -d "${PLUGIN_PATH}/historian/" \
  && rm master.zip \
  && chmod -x $PLUGIN_PATH/historian/historian-cli ## we do not want CLN to think this is a plugin at startup

RUN cd $PLUGIN_PATH/historian \
  && poetry install

RUN apt remove -qfy wget unzip jq autoconf automake build-essential git
RUN apt clean && apt autoclean \
  && pip3 uninstall -y poetry --break-system-packages
