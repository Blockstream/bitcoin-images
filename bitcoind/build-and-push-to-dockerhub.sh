#!/bin/sh
set -ex

export VER=${VER:-29.1}
docker buildx build --platform linux/amd64,linux/arm64 \
  --push \
  --cache-from blockstream/bitcoind:latest \
  --build-arg BITCOIN_VERSION=${VER} \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  -t blockstream/bitcoind:${VER} . || { printf '\nSomething broke\n'; exit 1; }

if [ "${LATEST:-0}" -eq 1 ]; then
  docker buildx imagetools create -t blockstream/bitcoind:latest blockstream/bitcoind:${VER}
fi
