#!/bin/sh

docker pull blockstream/liquidd-legacy:latest || true
docker build --cache-from blockstream/liquidd-legacy:latest -t blockstream/liquidd-legacy:latest . || (echo -e "\nSomething broke" && exit 1)
docker push blockstream/liquidd-legacy:latest

SHA=$(docker inspect --format='{{index .RepoDigests 0}}' blockstream/liquidd-legacy:latest)

echo -e "The new image is:\n${SHA}"
