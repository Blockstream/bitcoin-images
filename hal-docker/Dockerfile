FROM rust:1.50-alpine

RUN apk --no-cache -u add bash curl jq git musl-dev

ENV VER=v0.6.1
RUN git clone https://github.com/stevenroose/hal.git -b ${VER} /opt/hal

WORKDIR /opt/hal

RUN cargo install hal
