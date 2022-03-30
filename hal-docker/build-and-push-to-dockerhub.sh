#!/bin/sh

export VER=0.8.0

#docker pull blockstream/hal-docker:latest
docker build -t blockstream/hal-docker:${VER} -t blockstream/hal-docker:latest . || { echo -e "\nSomething broke"; exit 1; }
docker push blockstream/hal-docker:${VER}
## Uncomment to push :latest tag
#docker push blockstream/hal-docker:latest

SHA=$(docker inspect --format='{{index .RepoDigests 0}}' blockstream/hal-docker:${VER})

echo "The new image is:\n${SHA}"
