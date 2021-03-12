### Dockerized Bitcoin RPC Proxy
https://github.com/Kixunil/btc-rpc-proxy
```
docker run -d --name=proxy blockstream/btc-rpc-proxy:latest btc_rpc_proxy --conf=/etc/btc-rpc-proxy/config.toml --default-fetch-blocks --verbose
```