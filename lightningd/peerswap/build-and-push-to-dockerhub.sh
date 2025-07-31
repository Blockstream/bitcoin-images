#!/usr/bin/env bash
set -ex

export CLN_VER=${CLN_VER:-v25.05}
export PS_VER=${PS_VER:-v5.0.0}
export BITCOIN_VER=${BITCOIN_VER:-27.2}
export ELEMENTS_VER=${ELEMENTS_VER:-23.3.0}

export IMAGE=blockstream/lightningd
export DOCKERFILE=debian.Dockerfile
export FLAVOR=${IMAGE}:${CLN_VER}-peerswap-debian
# export DOCKERFILE=Dockerfile
# export FLAVOR=${IMAGE}:${CLN_VER}-peerswap

# --platform linux/amd64,arm64 \
docker buildx build \
    --platform linux/amd64 \
    --push \
    --cache-from ${FLAVOR} \
    --build-arg CLN_VER=${CLN_VER} \
    --build-arg PEERSWAP_VER=${PS_VER} \
    --build-arg BITCOIN_VER=${BITCOIN_VER} \
    --build-arg ELEMENTS_VER=${ELEMENTS_VER} \
    -t ${FLAVOR} \
    -f ${DOCKERFILE} \
    -t ${FLAVOR}-${PS_VER} . || { echo -e "\nSomething broke"; exit 1; }
