FROM alpine@sha256:85e16a753e459ea44a8aa1dfc1cb8b625f9c487b00ea686384a96923a3691f4e

ARG BITCOIN_VERSION
ENV BITCOIN_VERSION=$BITCOIN_VERSION
ENV WLADIMIRVDL_PGP_KEY=71A3B16735405025D447E8F274810B012346C9A6
ENV ACHOW_PGP_KEY=152812300785C96444D3334D17565732E08E5E41
ENV GLIBC_VERSION=2.33-r0

WORKDIR /opt/bitcoin

RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk

RUN apk update \
  && apk --no-cache --virtual temp add coreutils ca-certificates gnupg \
	&& apk --no-cache add bash \
 	&& apk --no-cache add glibc-${GLIBC_VERSION}.apk \
	&& apk --no-cache add glibc-bin-${GLIBC_VERSION}.apk

RUN wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz \
  && wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS.asc \
  && wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS

RUN gpg --keyserver hkps://keys.openpgp.org --recv-keys ${WLADIMIRVDL_PGP_KEY} ${ACHOW_PGP_KEY} \
  && csplit -ksz SHA256SUMS.asc  /-----BEGIN/ '{*}' \
  && for i in xx*; do gpg --verify $i SHA256SUMS && break; done \
  && grep bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz SHA256SUMS | sha256sum -c

RUN mkdir -p bitcoin /root/.bitcoin \
  && tar xzvf bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz --strip-components=1 -C bitcoin \
	&& mv bitcoin/bin/* /usr/local/bin/ \
  && mv bitcoin/lib/* /usr/local/lib/ \
  && mv bitcoin/share/* /usr/local/share/

RUN apk del temp \
	&& rm -rf glibc-* bitcoin* xx*
