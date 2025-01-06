#!/bin/sh
set -ex

export VER=${VER:-27.0}
docker buildx build --platform linux/amd64,linux/arm64 \
  --push \
  --cache-from blockstream/bitcoind:latest \
  --build-arg BITCOIN_VERSION=${VER} \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  -t blockstream/bitcoind:${VER} . || { echo -e "\nSomething broke"; exit 1; }

if [[ $LATEST -eq 1 ]]
then
  docker buildx imagetools create -t blockstream/bitcoind:latest blockstream/bitcoind:${VER}
fi
