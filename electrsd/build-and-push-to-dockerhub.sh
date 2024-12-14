#!/bin/sh
set -ex

export VER=a33e97e1a1fc63fa9c20a116bb92579bbf43b254

docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --push \
    --cache-from blockstream/electrsd-liquid:latest \
    --build-arg ELECTRSD_VERSION=${VER} \
    -t blockstream/electrsd-liquid:$VER \
    -t blockstream/electrsd-liquid:latest . || `echo -e "\nSomething broke" && exit 1`
