#!/bin/sh

export VER=22.0

docker pull blockstream/bitcoind:latest
#docker build -t blockstream/bitcoind:${VER} -f Dockerfile.gitian . || { echo -e "\nSomething broke"; exit 1; }
docker build -t blockstream/bitcoind:${VER} . || { echo -e "\nSomething broke"; exit 1; }
docker push blockstream/bitcoind:${VER}
## Uncomment to push :latest tag
#docker tag blockstream/bitcoind:${VER} blockstream/bitcoind:latest
#docker push blockstream/bitcoind:latest

SHA=$(docker inspect --format='{{index .RepoDigests 0}}' blockstream/bitcoind:${VER})

echo -e "The new image is:\n${SHA}"
