#!/bin/sh

export VER=v0.8.1

docker pull blockstream/lightningd:latest
docker build --cache-from blockstream/lightningd:latest -t blockstream/lightningd:${VER} -t blockstream/lightningd:latest . || { echo -e "\nSomething broke"; exit 1; }
docker push blockstream/lightningd:latest
docker push blockstream/lightningd:${VER}

SHA=$(docker inspect --format='{{index .RepoDigests 0}}' blockstream/lightningd:latest)

echo -e "The new image is:\n${SHA}"
