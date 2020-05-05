#!/bin/sh

export VER=0.19.1

docker pull blockstream/bitcoind:latest
#docker build --cache-from blockstream/bitcoind:latest -t blockstream/bitcoind:${VER} -f Dockerfile.gitian . || { echo -e "\nSomething broke"; exit 1; }
docker build --cache-from blockstream/bitcoind:latest -t blockstream/bitcoind:${VER} . || { echo -e "\nSomething broke"; exit 1; }
docker push blockstream/bitcoind:${VER}
## Uncomment to push :latest tag
docker tag blockstream/bitcoind:${VER} blockstream/bitcoind:latest
docker push blockstream/bitcoind:latest

SHA=$(docker inspect --format='{{index .RepoDigests 0}}' blockstream/bitcoind:${VER})

echo -e "The new image is:\n${SHA}"
