ARG CLN_VER=latest
FROM blockstream/lightningd:${CLN_VER}

# Install plugin dependencies
RUN apt install -qfy jq autoconf automake build-essential git libtool libsqlite3-dev libffi-dev \
    python3 python3-pip net-tools zlib1g-dev libsodium-dev gettext wget unzip pkg-config libpq-dev
RUN pip3 install --break-system-packages poetry psycopg2

ENV PLUGIN_PATH=/opt/plugins

# Add custom plugins (connection pool, historian)
COPY connectionpool.py $PLUGIN_PATH/connectionpool.py
RUN mkdir -p $PLUGIN_PATH/historian/cli \
  && wget -q https://github.com/lightningd/plugins/archive/master.zip \
  && unzip -qqj master.zip "plugins-master/archived/historian/cli/*" -d "${PLUGIN_PATH}/historian/cli" \
  && unzip -qqj master.zip "plugins-master/archived/historian/*" -x "plugins-master/archived/historian/cli/*" -d "${PLUGIN_PATH}/historian/" \
  && rm master.zip \
  && chmod -x $PLUGIN_PATH/historian/historian-cli ## we do not want CLN to think this is a plugin at startup

# Sometimes the historian plugin is behind the main image's python package versions so we need to downgrade
## Disabling poetry's venvs and PIP_BREAK_SYSTEM_PACKAGES=1 allow for that
RUN cd $PLUGIN_PATH/historian \
    && poetry config virtualenvs.create false \
    && PIP_BREAK_SYSTEM_PACKAGES=1 poetry install --no-root --only main

RUN apt remove -qfy wget unzip jq autoconf automake build-essential git
RUN apt clean && apt autoclean \
  && pip3 uninstall -y poetry --break-system-packages
