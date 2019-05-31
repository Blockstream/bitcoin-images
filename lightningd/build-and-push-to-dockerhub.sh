#!/bin/sh

docker pull blockstream/lightningd:latest
docker build --cache-from blockstream/lightningd:latest -t blockstream/lightningd:v0.7.0 . || `echo -e "\nSomething broke" && exit 1`
docker push blockstream/lightningd:v0.7.0

SHA=$(docker inspect --format='{{index .RepoDigests 0}}' blockstream/lightningd:v0.7.0)

echo -e "The new image is:\n${SHA}"
