FROM blockstream/lightningd:v23.05.2

# Install plugin dependencies
RUN apk add --virtual deps gcc musl-dev postgresql-dev python3-dev libffi-dev make wget
RUN pip3 install --upgrade pip wheel psycopg2-binary

## this takes care of missing deps
RUN pip3 install -r https://raw.githubusercontent.com/lightningd/plugins/38d1f337a934ba04290344bf0f268fc1d49bc3e0/historian/requirements.txt

ENV PLUGIN_PATH=/opt/plugins

# Add custom plugins (connection pool, historian)
COPY connectionpool.py $PLUGIN_PATH/connectionpool.py
RUN mkdir -p $PLUGIN_PATH/historian/cli \
  && wget -q https://github.com/lightningd/plugins/archive/master.zip \
  && unzip -qqj master.zip "plugins-master/historian/cli/*" -d "${PLUGIN_PATH}/historian/cli" \
  && unzip -qqj master.zip "plugins-master/historian/*" -x "plugins-master/historian/cli/*" -d "${PLUGIN_PATH}/historian/" \
  && rm master.zip \
  && chmod -x $PLUGIN_PATH/historian/historian-cli ## we do not want CLN to think this is a plugin at startup

RUN apk --purge del deps
