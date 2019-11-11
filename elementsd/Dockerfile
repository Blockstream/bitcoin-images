FROM alpine@sha256:769fddc7cc2f0a1c35abb2f91432e8beecf83916c421420e6a6da9f8975464b6

ENV ELEMENTS_VERSION=0.18.1.2
ENV ELEMENTS_PGP_KEY=11D43A27826A421212108BF66BE2CED14A9917BC
ENV GLIBC_VERSION=2.28-r0

WORKDIR /opt/elements

RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk 

RUN apk update \
	&& apk --no-cache add ca-certificates wget gnupg bash \
  && apk --no-cache add glibc-${GLIBC_VERSION}.apk \
  && apk --no-cache add glibc-bin-${GLIBC_VERSION}.apk

RUN wget https://github.com/ElementsProject/elements/releases/download/elements-${ELEMENTS_VERSION}/elements-${ELEMENTS_VERSION}-x86_64-linux-gnu.tar.gz \
 && wget https://github.com/ElementsProject/elements/releases/download/elements-${ELEMENTS_VERSION}/SHA256SUMS.asc

RUN gpg --keyserver keyserver.ubuntu.com --recv-keys ${ELEMENTS_PGP_KEY} \
  && gpg --verify SHA256SUMS.asc \
  && grep elements-${ELEMENTS_VERSION}-x86_64-linux-gnu.tar.gz SHA256SUMS.asc | sha256sum -c \
  && mkdir elements \
  && tar xzvf elements-${ELEMENTS_VERSION}-x86_64-linux-gnu.tar.gz -C elements \
  && mkdir /root/.elements \
  && apk del wget ca-certificates \
  && cp elements/bin/* /usr/local/bin/ \
  && mv elements/lib/* /usr/local/lib/ \
  && mv elements/include/* /usr/local/include/ \
  && mv elements/share/* /usr/local/share/ \
  && rm -rf elements* \
  && rm -rf glibc-*
