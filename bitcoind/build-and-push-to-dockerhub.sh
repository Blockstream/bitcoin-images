#!/bin/bash
set -ex

export VER=${VER:-24.1}

docker pull blockstream/bitcoind:latest
docker build --network=host \
  --build-arg BITCOIN_VERSION=${VER} \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  -t blockstream/bitcoind:${VER} . || { echo -e "\nSomething broke"; exit 1; }
docker push blockstream/bitcoind:${VER}

if [[ $LATEST -eq 1 ]]
then
  docker tag blockstream/bitcoind:${VER} blockstream/bitcoind:latest
  docker push blockstream/bitcoind:latest
fi

SHA=$(docker inspect --format='{{index .RepoDigests 0}}' blockstream/bitcoind:${VER})

echo -e "The new image is:\n${SHA}"
