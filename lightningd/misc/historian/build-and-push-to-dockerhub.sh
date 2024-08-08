#!/usr/bin/env bash
set -ex

export VER=${VER:-v24.05-historian}

docker pull blockstream/lightningd:latest
docker build --network=host \
  -t blockstream/lightningd:${VER} . || { echo -e "\nSomething broke"; exit 1; }
docker push blockstream/lightningd:${VER}

SHA=$(docker inspect --format='{{index .RepoDigests 0}}' blockstream/lightningd:${VER})

echo -e "The new image is:\n${SHA}"

