FROM rust:1.59-alpine

ENV VER=0.8.0

RUN apk --no-cache -u add bash curl jq git musl-dev

WORKDIR /opt/hal

RUN cargo install hal --vers $VER
RUN cargo install hal-elements
