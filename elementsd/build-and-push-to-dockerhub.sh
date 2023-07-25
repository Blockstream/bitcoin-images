#!/usr/bin/env bash
set -ex

export VER=${VER:-22.1.1}

docker pull blockstream/elementsd:latest
docker build --network=host \
  --build-arg ELEMENTS_VERSION=${VER} \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  -t blockstream/elementsd:${VER} . || { echo -e "\nSomething broke"; exit 1; }
docker push blockstream/elementsd:${VER}

if [[ $LATEST -eq 1 ]]
then
  docker tag blockstream/elementsd:${VER} blockstream/elementsd:latest
  docker push blockstream/elementsd:latest
fi

SHA=$(docker inspect --format='{{index .RepoDigests 0}}' blockstream/elementsd:${VER})

echo -e "The new image is:\n${SHA}"
