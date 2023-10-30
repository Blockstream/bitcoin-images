#!/usr/bin/env bash
set -ex

export VER=v0.4.26

docker pull blockstream/charged:latest
docker build --network=host \
  --build-arg CHARGED_VERSION=${VER} \
  --cache-from blockstream/charged:latest \
  -t blockstream/charged:${VER} . || { echo -e "\nSomething broke" && exit 1; }
docker push blockstream/charged:${VER}

if [[ $LATEST -eq 1 ]]
then
  docker tag blockstream/charged:${VER} blockstream/charged:latest
  docker push blockstream/charged:latest
fi


SHA=$(docker inspect --format='{{index .RepoDigests 0}}' blockstream/charged:latest)

echo -e "The new image is:\n${SHA}"
