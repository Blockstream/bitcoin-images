FROM node:lts-slim AS builder

ARG CHARGED_VERSION
ENV CHARGED_VERSION=$CHARGED_VERSION

WORKDIR /opt/charged

RUN apt-get update && apt-get install -y git

# Build charged
RUN git clone https://github.com/ElementsProject/lightning-charge.git -b ${CHARGED_VERSION} /opt/charged \
  && npm install \
  && npm run dist \
  && rm -rf src test

FROM node:lts-slim

COPY --from=builder /opt/charged /opt/charged

WORKDIR /opt/charged
ENV HOME /root
ENV NODE_ENV production

RUN apt-get update && apt-get install -y --no-install-recommends \
    inotify-tools libgmp-dev libsqlite3-dev \
  && rm -rf /var/lib/apt/lists/* \
  && ln -sf /opt/charged/bin/charged /usr/bin/charged \
  && mkdir /data
