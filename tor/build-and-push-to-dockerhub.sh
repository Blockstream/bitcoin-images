#!/bin/sh

docker pull blockstream/tor:latest
docker build --cache-from blockstream/tor:latest -t blockstream/tor:latest . || `echo -e "\nSomething broke" && exit 1`
docker push blockstream/tor:latest

SHA=$(docker inspect --format='{{index .RepoDigests 0}}' blockstream/tor:latest)

echo -e "The new image is:\n${SHA}"
