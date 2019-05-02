FROM alpine@sha256:28ef97b8686a0b5399129e9b763d5b7e5ff03576aa5580d6f4182a49c5fe1913

ENV SHA256SUM_LIQUID=cb135d60407fd4fcd04d1f021cd314e9f8f50a8f0a660551f5ea251b0fea3ffc
ENV LIQUID_VERSION=3.14.1.23
ENV GLIBC_VERSION=2.28-r0

WORKDIR /opt/liquid

RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk 

RUN apk update \
	&& apk --no-cache add ca-certificates gnupg bash \
  && apk --no-cache add glibc-${GLIBC_VERSION}.apk \
  && apk --no-cache add glibc-bin-${GLIBC_VERSION}.apk

RUN wget -O liquid.tar.gz https://github.com/Blockstream/liquid/releases/download/liquid.${LIQUID_VERSION}/liquid-${LIQUID_VERSION}-x86_64-linux-gnu.tar.gz \
  && echo "${SHA256SUM_LIQUID}  liquid.tar.gz" | sha256sum -c \
  && tar xzvf liquid.tar.gz \
  && mkdir /root/.liquid \
  && apk del wget ca-certificates \
  && cp liquid-${LIQUID_VERSION}/bin/* /usr/local/bin/ \
  && rm -rf liquid* \
  && rm -rf glibc-*
