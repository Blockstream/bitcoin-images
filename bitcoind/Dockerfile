FROM alpine@sha256:769fddc7cc2f0a1c35abb2f91432e8beecf83916c421420e6a6da9f8975464b6

ENV BITCOIN_VERSION=0.18.1
ENV BITCOIN_PGP_KEY=01EA5486DE18A882D4C2684590C8019E36C2E964
ENV GLIBC_VERSION=2.28-r0

WORKDIR /opt/bitcoin

RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk \
 && wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS.asc \
 && wget -O bitcoin.tar.gz https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz

RUN apk update \
	&& apk --no-cache add ca-certificates gnupg bash \
 	&& apk --no-cache add glibc-${GLIBC_VERSION}.apk \
	&& apk --no-cache add glibc-bin-${GLIBC_VERSION}.apk

RUN gpg --keyserver keyserver.ubuntu.com --recv-keys ${BITCOIN_PGP_KEY} \
  && gpg --verify SHA256SUMS.asc \
  && grep bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz SHA256SUMS.asc | sha256sum -c \
  && mkdir bitcoin \
	&& tar xzvf bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz -C bitcoin \
	&& mkdir /root/.bitcoin \
	&& apk del wget ca-certificates \
	&& mv bitcoin/bin/* /usr/local/bin/ \
  && mv bitcoin/lib/* /usr/local/lib/ \
  && mv bitcoin/include/* /usr/local/include/ \
  && mv bitcoin/share/* /usr/local/share/ \
	&& rm -rf bitcoin* \
	&& rm -rf glibc-*
