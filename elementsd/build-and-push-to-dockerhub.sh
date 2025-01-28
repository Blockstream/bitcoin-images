#!/bin/sh
set -ex

export VER=${VER:-23.2.5}
docker buildx build --platform linux/amd64,linux/arm64 \
  --push \
  --cache-from blockstream/elementsd:latest \
  --build-arg ELEMENTS_VERSION=${VER} \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  -t blockstream/elementsd:${VER} . || { echo -e "\nSomething broke"; exit 1; }

if [[ $LATEST -eq 1 ]]
then
  docker buildx imagetools create -t blockstream/elementsd:latest blockstream/elementsd:${VER}
fi
