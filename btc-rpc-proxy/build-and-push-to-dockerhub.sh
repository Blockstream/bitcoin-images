#!/bin/sh
set -ex

export VER=v0.3.0

docker pull blockstream/btc-rpc-proxy:latest || true
docker build --cache-from blockstream/btc-rpc-proxy:latest -t blockstream/btc-rpc-proxy:${VER} . || { echo -e "\nSomething broke"; exit 1; }
docker push blockstream/btc-rpc-proxy:${VER}
## Uncomment to push :latest tag
docker tag blockstream/btc-rpc-proxy:${VER} blockstream/btc-rpc-proxy:latest
docker push blockstream/btc-rpc-proxy:latest

SHA=$(docker inspect --format='{{index .RepoDigests 0}}' blockstream/btc-rpc-proxy:${VER})

echo "The new image is:\n${SHA}"
