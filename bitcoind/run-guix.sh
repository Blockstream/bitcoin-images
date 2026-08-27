#!/usr/bin/env bash

set -euo pipefail

BITCOIN_VERSION=${BITCOIN_VERSION:-v31.1}
BITCOIN_DIR=${BITCOIN_VERSION#v}
HOSTS=${HOSTS:-x86_64-linux-gnu}
JOBS=${JOBS:-2}

if [ "${HOSTS}" != "x86_64-linux-gnu" ]; then
  echo "Dockerfile.guix expects a single x86_64-linux-gnu ./bitcoin payload." >&2
  echo "Set HOSTS=x86_64-linux-gnu or adapt Dockerfile.guix for your target." >&2
  exit 1
fi

if ! command -v guix >/dev/null 2>&1; then
  echo "Bitcoin Core ${BITCOIN_VERSION} uses Guix for reproducible builds; install Guix first." >&2
  echo "See: https://github.com/bitcoin/bitcoin/blob/${BITCOIN_VERSION}/contrib/guix/INSTALL.md" >&2
  exit 1
fi

rm -rf bitcoin
if [ -d bitcoin-src/.git ]; then
  git -C bitcoin-src fetch --depth 1 origin tag "${BITCOIN_VERSION}"
  git -C bitcoin-src checkout --detach "${BITCOIN_VERSION}"
else
  git clone --branch "${BITCOIN_VERSION}" --depth 1 https://github.com/bitcoin/bitcoin.git bitcoin-src
fi

(
  cd bitcoin-src
  rm -rf "guix-build-${BITCOIN_DIR}/distsrc-${BITCOIN_DIR}-${HOSTS}"
  env HOSTS="${HOSTS}" JOBS="${JOBS}" ./contrib/guix/guix-build
)

mkdir bitcoin
tarball=$(find bitcoin-src/guix-build-*/output -name "bitcoin-${BITCOIN_DIR}-x86_64-linux-gnu.tar.gz" -print -quit)
if [ -z "${tarball}" ]; then
  echo "Could not find Guix output tarball for bitcoin-${BITCOIN_DIR}-x86_64-linux-gnu.tar.gz" >&2
  exit 1
fi

tar -xzvf "${tarball}" --strip-components 1 -C bitcoin
