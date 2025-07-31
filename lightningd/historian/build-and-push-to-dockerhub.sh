#!/usr/bin/env bash
set -ex

export CLN_VER=${CLN_VER:-v25.05}

docker buildx build \
    --platform linux/amd64 \
    --push \
    --cache-from blockstream/lightningd:latest \
    --build-arg CLN_VER=${CLN_VER} \
    -t blockstream/lightningd:${CLN_VER}-historian . || { echo -e "\nSomething broke"; exit 1; }
