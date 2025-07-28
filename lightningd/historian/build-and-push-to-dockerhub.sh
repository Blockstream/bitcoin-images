#!/bin/sh
set -ex

export VER=${VER:-v24.08.2}

docker buildx build \
    --platform linux/amd64 \
    --push \
    --cache-from blockstream/lightningd:latest \
    --build-arg VER=${VER} \
    -t blockstream/lightningd:${VER}-historian . || { echo -e "\nSomething broke"; exit 1; }
