FROM blockstream/lightningd:v24.05

# Install plugin dependencies
RUN apk add --virtual deps alpine-sdk autoconf automake libtool postgresql-dev python3-dev libffi-dev wget
RUN pip3 install --upgrade pip wheel poetry psycopg2-binary inotify sqlalchemy python-dotenv

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

RUN apk --purge del deps \
  && pip3 uninstall -y poetry
