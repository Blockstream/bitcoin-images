#!/usr/bin/env bash

export VER=v0.10.2
docker pull blockstream/lightningd:latest
docker build -t blockstream/lightningd:${VER} -t blockstream/lightningd:latest . || { echo -e "\nSomething broke"; exit 1; }
docker push blockstream/lightningd:latest
docker push blockstream/lightningd:${VER}
SHA=$(docker inspect --format='{{index .RepoDigests 0}}' blockstream/lightningd:latest)

# armv7 
#docker build -f Dockerfile.armv7 -t blockstream/lightningd:${VER}-armv7 . || { echo -e "\nSomething broke"; exit 1; }
#docker push blockstream/lightningd:${VER}-armv7
#SHA=$(docker inspect --format='{{index .RepoDigests 0}}' blockstream/lightningd:${VER}-armv7)

echo -e "The new image is:\n${SHA}"
