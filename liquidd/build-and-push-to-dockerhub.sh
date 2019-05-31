#!/bin/sh

docker pull blockstream/liquidd:latest
docker build --cache-from blockstream/liquidd:latest -t blockstream/liquidd:latest . || `echo -e "\nSomething broke" && exit 1`
docker push blockstream/liquidd:latest

SHA=$(docker inspect --format='{{index .RepoDigests 0}}' blockstream/liquidd:latest)

echo -e "The new image is:\n${SHA}"
