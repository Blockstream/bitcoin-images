#!/usr/bin/env bash
set -ex

export VER=${VER:-v24.08.2}
export PS_VER=${PS_VER:-513f0c6}

export IMAGE=blockstream/lightningd
export DOCKERFILE=debian.Dockerfile
export FLAVOR=${IMAGE}:${VER}-peerswap-debian
# export DOCKERFILE=Dockerfile
# export FLAVOR=${IMAGE}:${VER}-peerswap

docker pull ${FLAVOR} || true
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
