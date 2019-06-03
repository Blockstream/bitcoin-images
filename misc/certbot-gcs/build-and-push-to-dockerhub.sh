#!/bin/sh

docker pull blockstream/certbot-gcs:latest
docker build --cache-from blockstream/certbot-gcs:latest -t blockstream/certbot-gcs:latest . || `echo -e "\nSomething broke" && exit 1`
docker push blockstream/certbot-gcs:latest

SHA=$(docker inspect --format='{{index .RepoDigests 0}}' blockstream/certbot-gcs:latest)

echo -e "The new image is:\n${SHA}"
