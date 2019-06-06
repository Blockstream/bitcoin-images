## Bitcoind
`Dockerfile` downloads the compiled binaries from https://bitcoincore.org. The file was adapted from https://github.com/jamesob/docker-bitcoind. Whereas `Dockerfile.gitian` uses [gitian](https://github.com/devrandom/gitian-builder) to build from [source](https://github.com/bitcoin/bitcoin).

Feel free to adapt the `build-and-push-to-dockerhub.sh` to push to your own repo/registry.

You can update Bitcoin's version in `Dockerfile` or `run-gitian.sh` based on the kind of image you want to build (e.g. `v0.17.1` or `commit_hash`).

### Building from source
If you're on MAC (or Windows), run inside an Ubuntu container (you need [Docker](https://docs.docker.com/install/#supported-platforms)) for this:
```
docker run -itd --name ub -v `pwd`/bitcoind:/opt/bitcoind -v /var/run/docker.sock:/var/run/docker.sock ubuntu:bionic sleep infinity
```
Open a shell inside the container (`docker exec -it ub bash`) and install necessary packages:
```
apt-get update && \
apt-get install -y git ruby apt-transport-https ca-certificates curl gnupg-agent software-properties-common && \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable" && \
apt-get update && apt-get install docker-ce -y
cd /opt/bitcoind 
./run_gitian.sh
```
You can watch the build logs by running `docker exec ub tail -f /opt/bitcoind/gitian/var/build.log` in another terminal window.
After gitian has finished successfully, you can `Ctrl+D` out of the container and remove it `docker rm -f ub`.

Lastly, you can build the actual docker image with the necessary Bitcoin binaries by
```
docker build -t blockstream/bitcoind:latest -f Dockerfile.gitian .
``` 
And possibly adapt `build-and-push-to-dockerhub.sh` to build from source as well. 
```
### How to run
```
/etc/systemd/system/bitcoin.service
[Unit]
Description=Bitcoin node
Wants=docker.target
After=docker.service

[Service]
Restart=always
RestartSec=3
ExecStartPre=/usr/bin/docker pull blockstream/bitcoind:latest
ExecStart=/usr/bin/docker run \
    --network=host \
    --pid=host \
    --name=bitcoin \
    -v /mnt/data/bitcoin/bitcoin.conf:/root/.bitcoin/bitcoin.conf:ro \
    -v /mnt/data/testnet:/root/.bitcoin:rw \
    blockstream/bitcoind:latest bitcoind -testnet -printtoconsole
ExecStop=/usr/bin/docker exec bitcoin bitcoin-cli stop
ExecStopPost=/usr/bin/sleep 3
ExecStopPost=/usr/bin/docker rm -f bitcoin
```
