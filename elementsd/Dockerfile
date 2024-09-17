FROM alpine:3.18.8

WORKDIR /opt/elements

ARG ELEMENTS_VERSION
ENV ELEMENTS_VERSION=$ELEMENTS_VERSION
ENV ELEMENTS_PGP_KEY="https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xbd0f3062f87842410b06a0432f656b0610604482"
ENV GH_DOWNLOAD=https://github.com/ElementsProject/elements/releases/download
ENV ELEMENTS_TARBALL=elements-${ELEMENTS_VERSION}-x86_64-linux-gnu.tar.gz

ENV GLIBC_VERSION=2.33-r0

RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk

RUN apk update \
	&& apk --no-cache --virtual deps add ca-certificates wget gnupg curl \
  && apk --no-cache add bash \
  # context for --force-overwrite https://github.com/sgerrand/alpine-pkg-glibc/issues/185
  && apk --no-cache add --force-overwrite glibc-${GLIBC_VERSION}.apk glibc-bin-${GLIBC_VERSION}.apk \
  && rm -rf glibc-*

RUN wget ${GH_DOWNLOAD}/elements-${ELEMENTS_VERSION}/${ELEMENTS_TARBALL} \
  && wget ${GH_DOWNLOAD}/elements-${ELEMENTS_VERSION}/SHA256SUMS.asc

RUN curl -s ${ELEMENTS_PGP_KEY} | gpg --import \
  && gpg --verify SHA256SUMS.asc \
  && grep ${ELEMENTS_TARBALL} SHA256SUMS.asc | sha256sum -c \
  && mkdir elements \
  && tar xzvf ${ELEMENTS_TARBALL} --strip-components=1 -C elements \
  && mkdir /root/.elements \
  && mv elements/bin/* /usr/local/bin/ \
  && mv elements/lib/* /usr/local/lib/ \
  && mv elements/share/* /usr/local/share/ \
  && rm -rf elements* \
  && apk --purge del deps

## Copy binary
# COPY elements-4b22137159d9-x86_64-linux-gnu.tar.gz /opt/elements/elements.tar.gz
# RUN curl -s ${ELEMENTS_PGP_KEY} | gpg --import \
#   && mkdir elements \
#   && tar xzvf elements.tar.gz --strip-components=1 -C elements \
#   && mkdir /root/.elements \
#   && mv elements/bin/* /usr/local/bin/ \
#   && mv elements/lib/* /usr/local/lib/ \
#   && mv elements/share/* /usr/local/share/ \
#   && rm -rf elements* \
#   && apk --purge del deps
