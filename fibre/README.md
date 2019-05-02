## Bitcoin Fibre 
Fibre is ran exactly like bitcoind with a few exceptions that are necessary in your `bitcoin.conf`. For more info: http://bitcoinfibre.org/fibre-howto.html.

### How to run
```
/etc/systemd/system/bitcoinfibre.service
[Unit]
Description=Bitcoin Fibre node
Wants=docker.target
After=docker.service

[Service]
Restart=always
RestartSec=3
ExecStartPre=/usr/bin/docker pull blockstream/bitcoinfibre:latest
ExecStart=/usr/bin/docker run \
    --network=host \
    --pid=host \
    --name=bitcoinfibre \
    -v /mnt/data/bitcoin/bitcoin.conf:/root/.bitcoin/bitcoin.conf:ro \
    -v /mnt/data/testnet:/root/.bitcoin:rw \
    blockstream/bitcoinfibre:latest bitcoind -testnet -printtoconsole
ExecStop=/usr/bin/docker exec bitcoinfibre bitcoin-cli stop
ExecStopPost=/usr/bin/sleep 3
ExecStopPost=/usr/bin/docker rm -f bitcoinfibre
```
