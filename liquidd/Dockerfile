FROM alpine@sha256:769fddc7cc2f0a1c35abb2f91432e8beecf83916c421420e6a6da9f8975464b6

ENV SHA256SUM_LIQUID=de1c4f7306b0b3f467e743c886a9b469f506acbfb91e19c617dd6a54c7cc9c41
ENV LIQUID_VERSION=0.17.0
ENV GLIBC_VERSION=2.28-r0

WORKDIR /opt/liquid

RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk 

RUN apk update \
	&& apk --no-cache add ca-certificates wget gnupg bash \
  && apk --no-cache add glibc-${GLIBC_VERSION}.apk \
  && apk --no-cache add glibc-bin-${GLIBC_VERSION}.apk

RUN wget -O liquid.tar.gz https://github.com/ElementsProject/elements/releases/download/elements-${LIQUID_VERSION}/liquid-${LIQUID_VERSION}-x86_64-linux-gnu.tar.gz \
  && echo "${SHA256SUM_LIQUID}  liquid.tar.gz" | sha256sum -c \
  && tar xzvf liquid.tar.gz \
  && mkdir /root/.liquid \
  && apk del wget ca-certificates \
  && cp liquid-${LIQUID_VERSION}/bin/* /usr/local/bin/ \
  && rm -rf liquid* \
  && rm -rf glibc-*
