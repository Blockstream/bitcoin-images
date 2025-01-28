#!/bin/sh
set -ex

export VER=${VER:-v24.08.2}
export PS_VER=${PS_VER:-3eadb6}

export IMAGE=blockstream/lightningd
export DOCKERFILE=debian.Dockerfile
export FLAVOR=${IMAGE}:${VER}-peerswap-debian
# export DOCKERFILE=Dockerfile
# export FLAVOR=${IMAGE}:${VER}-peerswap

# --platform linux/amd64,arm64 \
docker buildx build \
    --platform linux/amd64 \
    --push \
    --cache-from ${FLAVOR} \
    --build-arg CLN_VERSION=${VER} \
    --build-arg PEERSWAP_COMMIT=${PS_VER} \
    -t ${FLAVOR} \
    -f ${DOCKERFILE} \
    -t ${FLAVOR}-${PS_VER} . || { echo -e "\nSomething broke"; exit 1; }
