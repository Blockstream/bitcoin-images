#!/bin/bash

set -v

ELEMENTS_VERSION=elements-0.21.0
ELEMENTS_DIR=0.21.0
export USE_DOCKER=1

git clone https://github.com/devrandom/gitian-builder.git gitian
git clone https://github.com/ElementsProject/elements -b ${ELEMENTS_VERSION} gitian/inputs/elements
sed -i '/50cacher$/d' gitian/bin/make-base-vm # don't use apt cache
cd gitian && bin/make-base-vm --docker --suite bionic

sed -i 's#HOSTS=.*#HOSTS="x86_64-linux-gnu"#' inputs/elements/contrib/gitian-descriptors/gitian-linux.yml
sed -i 's#CONFIGFLAGS=.*#CONFIGFLAGS="--without-gui --enable-glibc-back-compat --enable-reduce-exports --disable-bench --disable-gui-tests"#' inputs/elements/contrib/gitian-descriptors/gitian-linux.yml
sed -i 's#.*QT_RCC.*##g' inputs/elements/contrib/gitian-descriptors/gitian-linux.yml
sed -i '0,/MAKEOPTS=(/{s/MAKEOPTS=(*/&NO_QT=1 /}' bin/gbuild

bin/gbuild --skip-fetch --num-make 2 --memory 4000 --url elements=inputs/elements --commit elements=${ELEMENTS_VERSION} inputs/elements/contrib/gitian-descriptors/gitian-linux.yml
mkdir ../elements && tar -xzvf build/out/elements-${ELEMENTS_DIR}-x86_64-linux-gnu.tar.gz --strip-components 1 -C ../elements
cd ../ && rm -rf gitian
