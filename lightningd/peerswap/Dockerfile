FROM blockstream/lightningd:v24.08.2 as builder
FROM golang:1.20-alpine3.18

RUN apk add --no-cache --upgrade curl gnupg

# Download elements binaries
ENV ELEMENTS_VERSION=22.1.1
ENV ELEMENTS_PGP_KEY="https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xbd0f3062f87842410b06a0432f656b0610604482"
ENV ELEMENTS_TARBALL=elements-${ELEMENTS_VERSION}-x86_64-linux-gnu.tar.gz

RUN wget https://github.com/ElementsProject/elements/releases/download/elements-${ELEMENTS_VERSION}/${ELEMENTS_TARBALL} \
 && wget https://github.com/ElementsProject/elements/releases/download/elements-${ELEMENTS_VERSION}/SHA256SUMS.asc

RUN curl -s ${ELEMENTS_PGP_KEY} | gpg --import \
  && gpg --verify SHA256SUMS.asc \
  && grep ${ELEMENTS_TARBALL} SHA256SUMS.asc | sha256sum -c
RUN mkdir /opt/elements \
  && tar xzvf ${ELEMENTS_TARBALL} --strip-components=1 -C /opt/elements \
  && rm ${ELEMENTS_TARBALL}
RUN mv /opt/elements/bin/* /usr/local/bin/ \
  && mv /opt/elements/lib/* /usr/local/lib/ \
  && mv /opt/elements/share/* /usr/local/share/ \
  && rm -rf /opt/elements SHA256SUMS.asc

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

# Copy binaries from builder
COPY --from=builder /usr/local/bin/* /usr/local/bin/
COPY --from=builder /usr/local/libexec /usr/local/libexec/
COPY --from=builder /usr/local/lib/libbitcoinconsensus* /usr/local/lib/
COPY --from=builder /usr/local/share/man1/bitcoin* /usr/local/share/man1/

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
ARG PEERSWAP_COMMIT=5935fb4656307a87cafde2513d54deec1c26f8f2
ENV PEERSWAP_COMMIT=$PEERSWAP_COMMIT
RUN git clone https://github.com/ElementsProject/peerswap.git -n $PLUGIN_PATH/ps \
  && cd $PLUGIN_PATH/ps \
  # allows to fetch PRs
  && git config --local --add remote.origin.fetch '+refs/pull/*/head:refs/remotes/origin/pr/*' \
  && git fetch \
  && git checkout $PEERSWAP_COMMIT \
  && make cln-release
  
RUN apk --purge del deps

ENTRYPOINT ["lightningd"]
CMD ["--help"]
