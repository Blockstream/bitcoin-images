ARG CLN_VER=v24.08.2
ARG ELEMENTS_VER=22.1.1
FROM blockstream/lightningd:${CLN_VER} as cln
FROM blockstream/elementsd:${ELEMENTS_VER} AS elementsd
FROM golang:1.20-alpine3.18

RUN apk add --no-cache --upgrade curl gnupg

# CLN deps
RUN apk add --no-cache ca-certificates gmp libgcc libsodium sqlite-libs zlib \
  inotify-tools socat bash gnupg py3-pip postgresql-libs

# Add GNU Lib C
ENV GLIBC_VERSION=2.33-r0
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk

RUN apk update \
  # context for --force-overwrite https://github.com/sgerrand/alpine-pkg-glibc/issues/185
  && apk --no-cache add --force-overwrite glibc-${GLIBC_VERSION}.apk glibc-bin-${GLIBC_VERSION}.apk \
  && rm -f glibc-*

# Copy CLN and Bitcoin binaries from cln + Elements from elementsd
COPY --from=cln /usr/local/bin/* /usr/local/bin/
COPY --from=cln /usr/local/libexec /usr/local/libexec/
COPY --from=cln /usr/local/lib/libbitcoinconsensus* /usr/local/lib/
COPY --from=cln /usr/local/share/man1/bitcoin* /usr/local/share/man1/
COPY --from=elementsd /usr/local/bin/* /usr/local/bin/
COPY --from=elementsd /usr/local/lib/* /usr/local/lib/
COPY --from=elementsd /usr/local/share/* /usr/local/share/

# Install plugin dependencies
ARG PLUGIN_PATH=/opt/plugins
ARG RAW_GH_PLUGINS=https://raw.githubusercontent.com/lightningd/plugins/3fc4ece1ba42bf69b4f8ab6f5683decada0502b2

RUN apk add --no-cache --virtual deps wget git make gcc musl-dev libffi-dev python3-dev
RUN pip3 install --upgrade pip wheel
RUN pip3 install -r $RAW_GH_PLUGINS/rebalance/requirements.txt \
                 -r $RAW_GH_PLUGINS/summary/requirements.txt \
                 prometheus-client==0.6.0 \
                 pyln-bolt7 \
                 pyln-proto

# Add custom plugins (rebalance, summary, prometheus)
RUN mkdir -p $PLUGIN_PATH \  
  && wget -q -O $PLUGIN_PATH/rebalance.py $RAW_GH_PLUGINS/rebalance/rebalance.py \
  && wget -q -O $PLUGIN_PATH/summary.py $RAW_GH_PLUGINS/summary/summary.py \
  && wget -q -O $PLUGIN_PATH/prometheus.py $RAW_GH_PLUGINS/archived/prometheus/prometheus.py \
  && chmod a+x $PLUGIN_PATH/* \
  && wget -q -O $PLUGIN_PATH/summary_avail.py $RAW_GH_PLUGINS/summary/summary_avail.py \
  && wget -q -O $PLUGIN_PATH/clnutils.py $RAW_GH_PLUGINS/rebalance/clnutils.py

# Add peerswap
ARG PEERSWAP_VER=5935fb4656307a87cafde2513d54deec1c26f8f2
ENV PEERSWAP_VER=${PEERSWAP_VER}
RUN git clone https://github.com/ElementsProject/peerswap.git -n $PLUGIN_PATH/ps \
  && cd $PLUGIN_PATH/ps \
  # allows to fetch PRs
  && git config --local --add remote.origin.fetch '+refs/pull/*/head:refs/remotes/origin/pr/*' \
  && git fetch \
  && git checkout ${PEERSWAP_VER} \
  && make cln-release
  
RUN apk --purge del deps

ENTRYPOINT ["lightningd"]
CMD ["--help"]
