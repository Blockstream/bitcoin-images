#!/usr/bin/env bash
set -ex

export VER=${VER:-v23.08}
export PS_VER=${PS_VER:-19eeea491fe39cad78302096b6b2bd922af61be8}

export IMAGE=blockstream/lightningd
export FLAVOR=${IMAGE}:${VER}-peerswap-debian
export DOCKERFILE=debian-paytest.Dockerfile

docker pull ${FLAVOR}
docker build \
  --network=host \
  --build-arg CLN_VERSION=${VER} \
  --build-arg PEERSWAP_COMMIT=${PS_VER} \
  -f ${DOCKERFILE} \
  -t ${FLAVOR}-${PS_VER} \
  --progress=plain \
  -t ${FLAVOR} . || { echo "Something broke"; exit 1; }

docker push ${FLAVOR}
docker push ${FLAVOR}-${PS_VER}

SHA=$(docker inspect --format='{{index .RepoDigests 0}}' ${FLAVOR})

echo "The new image is:\n${SHA}"
