#!/bin/sh
set -ex

export CLN_VER=${CLN_VER:-v24.08.2}

docker buildx build \
    --platform linux/amd64 \
    --push \
    --cache-from blockstream/lightningd:latest \
    --build-arg CLN_VER=${CLN_VER} \
    -t blockstream/lightningd:${CLN_VER}-historian . || { echo -e "\nSomething broke"; exit 1; }
