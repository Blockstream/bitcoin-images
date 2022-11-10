# 3.14.4
FROM alpine@sha256:a8c98a08ab965e9a033a8266e519519a7b615c01d22c6790a47d5853716a8726

ENV ELEMENTS_VERSION=22.0.2
ENV ELEMENTS_PGP_KEY=BD0F3062F87842410B06A0432F656B0610604482
ENV GLIBC_VERSION=2.33-r0

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
  && tar xzvf elements-${ELEMENTS_VERSION}-x86_64-linux-gnu.tar.gz --strip-components=1 -C elements \
  && mkdir /root/.elements \
  && mv elements/bin/* /usr/local/bin/ \
  && mv elements/lib/* /usr/local/lib/ \
  && mv elements/share/* /usr/local/share/ \
  && apk del wget ca-certificates \
  && rm -rf elements* \
  && rm -rf glibc-*
