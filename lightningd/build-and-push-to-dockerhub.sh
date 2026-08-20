#!/usr/bin/env bash
set -ex

export VER=${VER:-v26.06.6}

docker buildx build \
  --platform linux/amd64 \
  --push \
  --cache-from blockstream/lightningd:latest \
  --build-arg VER=${VER} \
  -t blockstream/lightningd:${VER} . || { echo -e "\nSomething broke"; exit 1; }

if [[ ${LATEST} -eq 1 ]]
then
  docker buildx imagetools create -t blockstream/lightningd:latest blockstream/lightningd:${VER}
fi
