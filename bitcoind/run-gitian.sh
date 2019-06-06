#!/bin/bash

set -v

BITCOIN_VERSION=v0.18.0
BITCOIN_DIR=0.18.0
export USE_DOCKER=1

git clone https://github.com/devrandom/gitian-builder.git gitian
git clone https://github.com/bitcoin/bitcoin -b ${BITCOIN_VERSION} gitian/inputs/bitcoin
cd gitian && bin/make-base-vm --docker --suite bionic

sed -i 's#HOSTS=.*#HOSTS="x86_64-linux-gnu"#' inputs/bitcoin/contrib/gitian-descriptors/gitian-linux.yml
sed -i 's#CONFIGFLAGS=.*#CONFIGFLAGS="--without-gui --enable-glibc-back-compat --enable-reduce-exports --disable-bench --disable-gui-tests"#' inputs/bitcoin/contrib/gitian-descriptors/gitian-linux.yml
sed -i 's#.*QT_RCC.*##g' inputs/bitcoin/contrib/gitian-descriptors/gitian-linux.yml
sed -i '0,/MAKEOPTS=(/{s/MAKEOPTS=(*/&NO_QT=1 /}' bin/gbuild

bin/gbuild --skip-fetch --num-make 2 --memory 4000 --url bitcoin=inputs/bitcoin --commit bitcoin=${BITCOIN_VERSION} inputs/bitcoin/contrib/gitian-descriptors/gitian-linux.yml
mkdir ../bitcoin && tar -xzvf build/out/bitcoin-${BITCOIN_DIR}-x86_64-linux-gnu.tar.gz --strip-components 1 -C ../bitcoin
cd ../ && rm -rf gitian