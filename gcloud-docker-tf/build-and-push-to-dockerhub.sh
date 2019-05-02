#!/bin/sh

docker pull blockstream/gcloud-docker:latest
docker build --cache-from blockstream/gcloud-docker:latest -t blockstream/gcloud-docker:latest . || (echo -e "\nSomething broke" && exit 1)
docker push blockstream/gcloud-docker:latest

SHA=$(docker inspect --format='{{index .RepoDigests 0}}' blockstream/gcloud-docker:latest)

echo -e "The new image is:\n${SHA}"
