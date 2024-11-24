#!/bin/sh
set -ex

export VER=v0.4.26

docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --push \
    --cache-from blockstream/charged:latest \
    -t blockstream/charged:$VERSION \
    -t blockstream/charged:latest . || `echo -e "\nSomething broke" && exit 1`
