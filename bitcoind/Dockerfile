FROM debian:bookworm-slim

ARG TARGETARCH TARGETOS
ARG BITCOIN_VERSION
ENV BITCOIN_VERSION=$BITCOIN_VERSION
ENV WLADIMIRVDL_PGP_KEY=71A3B16735405025D447E8F274810B012346C9A6
ENV ACHOW_PGP_KEY=152812300785C96444D3334D17565732E08E5E41

WORKDIR /opt/bitcoin

RUN apt update \
  && apt install -qfy ca-certificates gnupg bash wget

RUN if [ "${TARGETARCH}" = "arm64" ]; then \
  wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/bitcoin-${BITCOIN_VERSION}-aarch64-linux-gnu.tar.gz; \
  else \
  wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz; \
  fi \
  && wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS.asc \
  && wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS

RUN gpg --keyserver hkps://keys.openpgp.org --recv-keys ${WLADIMIRVDL_PGP_KEY} ${ACHOW_PGP_KEY} \
  && csplit -ksz SHA256SUMS.asc  /-----BEGIN/ '{*}' \
  && for i in xx*; do gpg --verify $i SHA256SUMS && break; done \
  && if [ "${TARGETARCH}" = "arm64" ]; then \
    grep bitcoin-${BITCOIN_VERSION}-aarch64-linux-gnu.tar.gz SHA256SUMS | sha256sum -c; \
  else \
    grep bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz SHA256SUMS | sha256sum -c; \
  fi

RUN mkdir -p bitcoin /root/.bitcoin \
  && if [ "${TARGETARCH}" = "arm64" ]; then \
    tar xzvf bitcoin-${BITCOIN_VERSION}-aarch64-linux-gnu.tar.gz --strip-components=1 -C bitcoin; \
  else \
    tar xzvf bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz --strip-components=1 -C bitcoin; \
  fi \
	&& mv bitcoin/bin/* /usr/local/bin/ \
  && mv bitcoin/lib/* /usr/local/lib/ || true \
  && mv bitcoin/include/* /usr/local/include/ || true \
  && mv bitcoin/share/* /usr/local/share/

RUN apt clean && apt autoclean
