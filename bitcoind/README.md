# Bitcoin

* `Dockerfile` downloads the compiled binaries from <https://bitcoincore.org>. The file was adapted from <https://github.com/jamesob/docker-bitcoind>
* `Dockerfile.guix` packages a locally built Bitcoin Core tree from `./bitcoin`. Bitcoin Core 31.1 uses [Guix](https://github.com/bitcoin/bitcoin/tree/v31.1/contrib/guix), not Gitian, for reproducible source builds.

The default Bitcoin Core version is `31.1` for downloaded binaries and `v31.1` for source builds. Override with `VER=...` for `build-and-push-to-dockerhub.sh` or `BITCOIN_VERSION=...` for `run-guix.sh`.

## Building from source

Install and configure Guix once by following Bitcoin Core's Guix setup guide:

<https://github.com/bitcoin/bitcoin/blob/v31.1/contrib/guix/INSTALL.md>

Then run the source build from this directory:

```bash
./run-guix.sh
```

`run-gitian.sh` and `Dockerfile.gitian` are kept as compatibility aliases for older commands. By default `run-guix.sh` builds the `x86_64-linux-gnu` release tarball and extracts it to `./bitcoin`.

Lastly, you can build the Docker image(s) with the Bitcoin binaries by specifying the appropriate Dockerfile:

```bash
docker build -t blockstream/bitcoind:tag_or_commit -f Dockerfile.guix .
```

Or feel free to adapt `build-and-push-to-dockerhub.sh` to build/push to your own repo/registry.
