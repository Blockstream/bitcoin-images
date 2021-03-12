FROM rust:1.50-alpine

RUN apk --no-cache -u add bash curl jq git musl-dev

ENV VER=v0.3.0

RUN cargo install --git https://github.com/Kixunil/btc-rpc-proxy.git --tag $VER
