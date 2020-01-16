## Bitcoind
* `Dockerfile` downloads the compiled binaries from https://bitcoincore.org. The file was adapted from https://github.com/jamesob/docker-bitcoind
* `Dockerfile.gitian` uses [gitian](https://github.com/devrandom/gitian-builder) to build from [source](https://github.com/bitcoin/bitcoin).

You can update Bitcoin's version in the `Dockerfile` or `run-gitian.sh` based on the version you want to build (e.g. `v0.18.1` or `commit_hash`).

### Building from source
If you're on MAC (or Windows), run inside an Ubuntu container (you need [Docker](https://docs.docker.com/install/#supported-platforms)). Assuming you've `git cloned && cd bitcoin-images`:
```
docker run -itd --name ub -v `pwd`/bitcoind:/opt/bitcoind -v /var/run/docker.sock:/var/run/docker.sock ubuntu:bionic sleep infinity
```
Open a shell inside the container (`docker exec -it ub bash`) and install the necessary packages:
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
You can watch the install or build logs by running `docker exec ub tail -f /opt/bitcoind/gitian/var/install|build.log` in another terminal window.
After gitian has finished successfully, you can `Ctrl+D` out of the container and remove it `docker rm -f ub`.

Lastly, you can build the Docker image(s) with the Bitcoin binaries by specifying the appropriate Dockerfile:
```
docker build -t blockstream/bitcoind:tag_or_commit -f Dockerfile.gitian .
``` 
Or feel free to adapt `build-and-push-to-dockerhub.sh` to build/push to your own repo/registry.
