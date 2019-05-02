#!/bin/sh

docker pull blockstream/bitcoinfibre:latest
docker build --cache-from blockstream/bitcoinfibre:latest -t blockstream/bitcoinfibre:latest . || (echo -e "\nSomething broke" && exit 1)
docker push blockstream/bitcoinfibre:latest

SHA=$(docker inspect --format='{{index .RepoDigests 0}}' blockstream/bitcoinfibre:latest)

echo -e "The new image is:\n${SHA}"
