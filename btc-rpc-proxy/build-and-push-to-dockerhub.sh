#!/bin/sh
set -ex

export VER=v0.4.0

docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --push \
    --cache-from blockstream/btc-rpc-proxy:latest \
    --build-arg VER=${VER} \
    -t blockstream/btc-rpc-proxy:${VER} \
    -t blockstream/btc-rpc-proxy:latest . || { echo -e "\nSomething broke"; exit 1; }
