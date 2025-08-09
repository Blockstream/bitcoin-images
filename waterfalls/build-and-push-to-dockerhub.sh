#!/bin/sh
set -ex

export WATERFALLS_REPO=https://github.com/RCasatta/waterfalls
export WATERFALLS_COMMIT_HASH=4abb0d99e7c26d4c1b06d69fa4c574475a46ffbd

docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --push \
    --cache-from blockstream/waterfalls:latest \
    --build-arg WATERFALLS_COMMIT_HASH=${WATERFALLS_COMMIT_HASH} \
    -t blockstream/waterfalls:$WATERFALLS_COMMIT_HASH \
    -t blockstream/waterfalls:latest . || `echo -e "\nSomething broke" && exit 1`

echo "pushed blockstream/waterfalls:$WATERFALLS_COMMIT_HASH"
echo "pushed blockstream/waterfalls:latest"

exit 0