## Liquidd
Running `liquidd` requires running [bitcoind](../bitcoind) as well.

Liquid's options are available by running `liquidd --help`.

### How to run
/etc/systemd/system/liquid.service
[Unit]
Description=Liquidd pseudo node
Wants=docker.target
After=docker.service

[Service]
Restart=always
RestartSec=3
ExecStartPre=/usr/bin/docker pull blockstream/liquidd:latest
ExecStart=/usr/bin/docker run \
    --network=host \
    --pid=host \
    --name=liquid \
    -v /mnt/data/liquid/liquid.conf:/root/.liquid/liquid.conf:ro \
    -v /mnt/data/liquid:/root/.liquid:rw \
    blockstream/liquidd:latest liquidd -printtoconsole
ExecStop=/usr/bin/docker exec liquid liquid-cli stop
ExecStopPost=/usr/bin/sleep 3
ExecStopPost=/usr/bin/docker rm -f liquid
