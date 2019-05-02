#!/bin/sh

docker pull blockstream/bitcoind:latest
docker build --cache-from blockstream/bitcoind:latest -t blockstream/bitcoind:latest . || (echo -e "\nSomething broke" && exit 1)
docker push blockstream/bitcoind:latest

SHA=$(docker inspect --format='{{index .RepoDigests 0}}' blockstream/bitcoind:latest)

echo -e "The new image is:\n${SHA}"
