## Bitcoind
`Dockerfile.binary` downloads the compiled binaries from https://bitcoincore.org. The file was adapted from https://github.com/jamesob/docker-bitcoind.

Feel free to adapt the `build-and-push-to-dockerhub.sh` to push to your own repo/registry.

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
