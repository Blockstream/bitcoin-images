#!/bin/sh

export VER=v0.18.1.3rc1

docker pull blockstream/elementsd:latest
docker build --cache-from blockstream/elementsd:latest -t blockstream/elementsd:${VER} . -f Dockerfile.gitian || `echo -e "\nSomething broke" && exit 1`
#docker build --cache-from blockstream/elementsd:latest -t blockstream/elementsd:${VER} . || `echo -e "\nSomething broke" && exit 1`
docker push blockstream/elementsd:${VER}
## Uncomment to push :latest tag 
# docker tag blockstream/elementsd:${VER} blockstream/elementsd:latest
#docker push blockstream/elementsd:latest

SHA=$(docker inspect --format='{{index .RepoDigests 0}}' blockstream/elementsd:${VER})

echo -e "The new image is:\n${SHA}"
