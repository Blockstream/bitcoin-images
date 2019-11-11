FROM alpine

ENV GLIBC_VERSION=2.28-r0
ENV LIQUID_VERSION=2.14.1.24

WORKDIR /opt/liquid

RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk

RUN apk update \
	&& apk --no-cache add ca-certificates wget gnupg bash \
  && apk --no-cache add glibc-${GLIBC_VERSION}.apk \
  && apk --no-cache add glibc-bin-${GLIBC_VERSION}.apk

RUN wget -O liquid-latest.tar.gz https://liquid-packages.blockstream.com/liquid-binary-repo/gitian/liquid-latest.tar.gz \
  & wget -O liquid-latest.tar.gz.asc https://liquid-packages.blockstream.com/liquid-binary-repo/gitian/liquid-latest.tar.gz.asc \
  && gpg --keyserver pgp.mit.edu --recv-keys EA3C448BB4A71A00 \
  && gpg --verify liquid-latest.tar.gz.asc \
  && tar xzvf liquid-latest.tar.gz \
  && mkdir /root/.liquid \
  && apk del wget ca-certificates \
  && cp liquid-${LIQUID_VERSION}/bin/* /usr/local/bin/ \
  && rm -rf liquid* \
  && rm -rf glibc-*
