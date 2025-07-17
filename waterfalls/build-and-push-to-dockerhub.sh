#!/bin/sh
set -ex

export VER=4abb0d99

docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --push \
    --cache-from blockstream/waterfalls:latest \
    --build-arg WATERFALLS_VERSION=${VER} \
    -t blockstream/waterfalls:$VER \
    -t blockstream/waterfalls:latest . || `echo -e "\nSomething broke" && exit 1`
