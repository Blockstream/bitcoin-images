#!/bin/sh

export VER=0.4.7.16-1

docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --push \
    --no-cache \
    --build-arg VER=${VER} \
    -t blockstream/tor:latest \
    -t blockstream/tor:${VER} . || { echo -e "\nSomething broke"; exit 1; }
