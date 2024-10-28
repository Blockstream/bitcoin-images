#!/usr/bin/env bash
set -ex

export VER=${VER:-v24.08.2}

docker pull blockstream/lightningd:latest
docker build --network=host \
  --build-arg CLN_VERSION=${VER} \
  -t blockstream/lightningd:${VER} . || { echo -e "\nSomething broke"; exit 1; }
docker push blockstream/lightningd:${VER}

if [[ $LATEST -eq 1 ]]
then
  docker tag blockstream/lightningd:${VER} blockstream/lightningd:latest
  docker push blockstream/lightningd:latest
fi

SHA=$(docker inspect --format='{{index .RepoDigests 0}}' blockstream/lightningd:${VER})

echo -e "The new image is:\n${SHA}"

# armv7 
#docker build -f Dockerfile.armv7 -t blockstream/lightningd:${VER}-armv7 . || { echo -e "\nSomething broke"; exit 1; }
#docker push blockstream/lightningd:${VER}-armv7
#SHA=$(docker inspect --format='{{index .RepoDigests 0}}' blockstream/lightningd:${VER}-armv7)

