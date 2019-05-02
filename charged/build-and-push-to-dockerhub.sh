#!/bin/sh

docker pull blockstream/charged:latest
docker build --cache-from blockstream/charged:latest -t blockstream/charged:latest . || (echo -e "\nSomething broke" && exit 1)
docker push blockstream/charged:latest

SHA=$(docker inspect --format='{{index .RepoDigests 0}}' blockstream/charged:latest)

echo -e "The new image is:\n${SHA}"
