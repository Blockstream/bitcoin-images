FROM debian:bookworm-slim

ARG TARGETARCH TARGETOS
ARG BITCOIN_VERSION=31.1
ENV BITCOIN_VERSION=$BITCOIN_VERSION
ENV WLADIMIRVDL_PGP_FINGERPRINT=71A3B16735405025D447E8F274810B012346C9A6
ENV ACHOW_PGP_FINGERPRINT=152812300785C96444D3334D17565732E08E5E41

WORKDIR /opt/bitcoin

RUN apt-get update \
  && apt-get install -qfy --no-install-recommends ca-certificates gnupg bash wget \
  && rm -rf /var/lib/apt/lists/*

RUN if [ "${TARGETARCH}" = "arm64" ]; then \
  wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/bitcoin-${BITCOIN_VERSION}-aarch64-linux-gnu.tar.gz; \
  else \
  wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz; \
  fi \
  && wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS.asc \
  && wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS

RUN gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys ${WLADIMIRVDL_PGP_FINGERPRINT} ${ACHOW_PGP_FINGERPRINT} \
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
  && for dir in include lib libexec share; do \
    if [ -d "bitcoin/${dir}" ]; then \
      mkdir -p "/usr/local/${dir}" && mv "bitcoin/${dir}"/* "/usr/local/${dir}/"; \
    fi; \
  done
