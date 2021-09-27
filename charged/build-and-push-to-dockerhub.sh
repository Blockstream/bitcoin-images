#!/bin/sh

VERSION=v0.4.23

docker pull blockstream/charged:latest
docker build --cache-from blockstream/charged:latest -t blockstream/charged:$VERSION . || `echo -e "\nSomething broke" && exit 1`
docker push blockstream/charged:$VERSION
docker tag blockstream/charged:$VERSION blockstream/charged:latest
docker push blockstream/charged:latest

SHA=$(docker inspect --format='{{index .RepoDigests 0}}' blockstream/charged:latest)

echo -e "The new image is:\n${SHA}"
