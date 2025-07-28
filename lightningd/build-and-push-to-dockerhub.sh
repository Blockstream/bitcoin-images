#!/bin/sh
set -ex

export CLN_VER=${CLN_VER:-v24.08.2}
export BITCOIN_VER=${BITCOIN_VER:-27.0}

# Skipping ARM, segmentation faults.
docker buildx build \
  --platform linux/amd64 \
  --push \
  --cache-from blockstream/lightningd:latest \
  --build-arg CLN_VER=${CLN_VER} \
  --build-arg BITCOIN_VER=${BITCOIN_VER} \
  -t blockstream/lightningd:${CLN_VER} . || { echo -e "\nSomething broke"; exit 1; }

if [[ $LATEST -eq 1 ]]
then
  docker buildx imagetools create -t blockstream/lightningd:latest blockstream/lightningd:${CLN_VER}
fi
