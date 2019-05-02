## Tor Hidden Service
The default `torrc` file is copied into the image, so feel free to change before building/using this image.
Feel free to adapt the `build-and-push-to-dockerhub.sh` to push to your own repo/registry.

### How to run
The `torrc` file that's included has some minor modifications from the default torrc file.

```
Description=Tor hidden service
Wants=docker.target
After=docker.service

[Service]
Restart=always
RestartSec=1
ExecStartPre=/usr/bin/docker pull blockstream/tor:latest
ExecStartPre=-/bin/chown -R user:user /mnt/data/tor
ExecStartPre=-/bin/chmod -R 2700 /mnt/data/tor
ExecStartPre=/sbin/iptables -A INPUT -m tcp -p tcp --dport 9050 -j ACCEPT
ExecStart=/usr/bin/docker run \
    --network=host \
    --pid=host \
    --name=tor \
    --tmpfs /tmp/ \
    -v /mnt/data/torrc:/home/tor/torrc:ro \
    -v /mnt/data/tor:/home/tor/tor:rw \
    blockstream/tor:latest tor -f /home/tor/torrc
ExecStop=/usr/bin/docker rm -f tor
```
