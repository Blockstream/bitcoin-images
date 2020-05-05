#!/bin/sh

export VER=0.4.2.7

docker pull blockstream/tor:latest
docker build --cache-from blockstream/tor:latest -t blockstream/tor:${VER} . || { echo -e "\nSomething broke"; exit 1; }
docker push blockstream/tor:${VER}
docker tag blockstream/tor:${VER} blockstream/tor:latest
docker push blockstream/tor:latest

SHA=$(docker inspect --format='{{index .RepoDigests 0}}' blockstream/tor:latest)

echo -e "The new image is:\n${SHA}"
