#!/bin/sh

export VER=0.9.5

docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --push \
    --cache-from blockstream/hal-docker:latest \
    --build-arg VER=${VER} \
    -t blockstream/hal-docker:${VER} \
    -t blockstream/hal-docker:latest . || { echo -e "\nSomething broke"; exit 1; }
