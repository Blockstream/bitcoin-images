#!/usr/bin/env bash
set -ex

export CLN_VER="${CLN_VER:-v26.06.7}"
export PS_VER="${PS_VER:-v7.0.0}"
export BITCOIN_VER="${BITCOIN_VER:-31.1}"
export ELEMENTS_VER="${ELEMENTS_VER:-23.3.3}"
export GO_VERSION="${GO_VERSION:-1.26.7}"
export RUST_VERSION="${RUST_VERSION:-1.98.0}"
export UV_VERSION="${UV_VERSION:-0.12.0}"
export PYLN_VERSION="${PYLN_VERSION:-26.6.6}"

export IMAGE="blockstream/lightningd"
export DOCKERFILE="Dockerfile"
export FLAVOR="${IMAGE}:${CLN_VER}-peerswap-debian"

# --platform linux/amd64,arm64 \
docker buildx build \
    --platform linux/amd64 \
    --push \
    --cache-from "${FLAVOR}" \
    --build-arg "CLN_VER=${CLN_VER}" \
    --build-arg "PEERSWAP_VER=${PS_VER}" \
    --build-arg "BITCOIN_VER=${BITCOIN_VER}" \
    --build-arg "ELEMENTS_VER=${ELEMENTS_VER}" \
    --build-arg "GO_VERSION=${GO_VERSION}" \
    --build-arg "RUST_VERSION=${RUST_VERSION}" \
    --build-arg "UV_VERSION=${UV_VERSION}" \
    --build-arg "PYLN_VERSION=${PYLN_VERSION}" \
    -t "${FLAVOR}" \
    -f "${DOCKERFILE}" \
    -t "${FLAVOR}-${PS_VER}" . || { echo -e "\nSomething broke"; exit 1; }
