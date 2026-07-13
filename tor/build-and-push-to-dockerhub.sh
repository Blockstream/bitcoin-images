#!/bin/sh

set -eu

TOR_VERSION=0.4.9.11
IMAGE="blockstream/tor:${TOR_VERSION}"

docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --push \
    --no-cache \
    --build-arg TOR_VERSION="${TOR_VERSION}" \
    -t "${IMAGE}" .

docker buildx imagetools inspect "${IMAGE}"
