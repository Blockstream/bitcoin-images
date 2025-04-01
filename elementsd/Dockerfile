FROM debian:bookworm-slim

ARG TARGETARCH TARGETOS
ARG ELEMENTS_VERSION
ARG GH_REPO=ElementsProject/elements

ENV ELEMENTS_VERSION=$ELEMENTS_VERSION
ENV GH_REPO=$GH_REPO
ENV PABLO_PGP_KEY=BD0F3062F87842410B06A0432F656B0610604482
ENV BYRON_PGP_KEY=710E44C2DAAE938F778744A1DE8F6EA20A661697
ENV GH_DOWNLOAD=https://github.com/${GH_REPO}/releases/download

ENV GLIBC_VERSION=2.33-r0

RUN apt update \
  && apt install -qfy ca-certificates wget gnupg bash

RUN if [ "${TARGETARCH}" = "arm64" ]; then \
    wget ${GH_DOWNLOAD}/elements-${ELEMENTS_VERSION}/elements-${ELEMENTS_VERSION}-aarch64-linux-gnu.tar.gz; \
  else \
    wget ${GH_DOWNLOAD}/elements-${ELEMENTS_VERSION}/elements-${ELEMENTS_VERSION}-x86_64-linux-gnu.tar.gz; \
  fi \
 && wget ${GH_DOWNLOAD}/elements-${ELEMENTS_VERSION}/SHA256SUMS.asc

RUN gpg --keyserver hkps://keys.openpgp.org --recv-keys ${BYRON_PGP_KEY} ${PABLO_PGP_KEY} \
  && gpg --output SHA256SUMS --decrypt SHA256SUMS.asc  \
  && if [ "${TARGETARCH}" = "arm64" ]; then \
      grep elements-${ELEMENTS_VERSION}-aarch64-linux-gnu.tar.gz SHA256SUMS | sha256sum -c; \
    else \
      grep elements-${ELEMENTS_VERSION}-x86_64-linux-gnu.tar.gz SHA256SUMS | sha256sum -c; \
    fi

RUN mkdir elements \
  && if [ "${TARGETARCH}" = "arm64" ]; then \
      tar xzvf elements-${ELEMENTS_VERSION}-aarch64-linux-gnu.tar.gz --strip-components=1 -C elements; \
    else \
      tar xzvf elements-${ELEMENTS_VERSION}-x86_64-linux-gnu.tar.gz --strip-components=1 -C elements; \
    fi \
  && mkdir /root/.elements \
  && mv elements/bin/* /usr/local/bin/ \
  && mv elements/lib/* /usr/local/lib/ \
  && mv elements/share/* /usr/local/share/

RUN apt-get clean && apt-get autoclean
