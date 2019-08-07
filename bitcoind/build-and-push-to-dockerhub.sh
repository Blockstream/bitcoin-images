#!/bin/sh

export VER=v0.18.1

docker pull blockstream/bitcoind:latest
docker build --cache-from blockstream/bitcoind:latest -t blockstream/bitcoind:${VER} . || `echo -e "\nSomething broke" && exit 1`
docker push blockstream/bitcoind:latest
docker push blockstream/bitcoind:${VER}

SHA=$(docker inspect --format='{{index .RepoDigests 0}}' blockstream/bitcoind:latest)

echo -e "The new image is:\n${SHA}"
