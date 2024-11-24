FROM rust:1.82-alpine

ARG VER
ENV VER=$VER

RUN apk --no-cache -u add bash curl jq git musl-dev

RUN cargo install --git https://github.com/Kixunil/btc-rpc-proxy.git --tag $VER
