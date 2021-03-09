#!/bin/sh

export VER=0.6.1

#docker pull blockstream/hal-docker:latest
docker build --cache-from hal-docker:latest -t blockstream/hal-docker:${VER} . || { echo -e "\nSomething broke"; exit 1; }
docker push blockstream/hal-docker:${VER}
## Uncomment to push :latest tag
docker tag blockstream/hal-docker:${VER} blockstream/hal-docker:latest
docker push blockstream/hal-docker:latest

SHA=$(docker inspect --format='{{index .RepoDigests 0}}' blockstream/hal-docker:${VER})

echo "The new image is:\n${SHA}"
