#!/bin/sh
set -ex

export BITCOIN_VERSION=${BITCOIN_VERSION:-27.0}
export VER=${VER:-v24.08.2}

# Skipping ARM, segmentation faults.
docker buildx build \
  --platform linux/amd64 \
  --push \
  --cache-from blockstream/lightningd:latest \
  --build-arg CLN_VERSION=${VER} \
  --build-arg BITCOIN_VERSION=${BITCOIN_VERSION} \
  -t blockstream/lightningd:${VER} . || { echo -e "\nSomething broke"; exit 1; }

if [[ $LATEST -eq 1 ]]
then
  docker buildx imagetools create -t blockstream/lightningd:latest blockstream/lightningd:${VER}
fi