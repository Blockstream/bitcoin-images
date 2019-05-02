FROM node:lts-slim AS builder

ENV CHARGED_VERSION=master

WORKDIR /opt/charged

RUN apt-get update && apt-get install -y --no-install-recommends git

# Build charged
RUN git clone https://github.com/ElementsProject/lightning-charge.git /opt/charged \
  && git checkout ${CHARGED_VERSION} \
  && npm install --production \
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
