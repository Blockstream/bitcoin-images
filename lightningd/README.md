## Lightningd
The Dockerfile was adapted from https://github.com/ElementsProject/lightning/blob/master/Dockerfile.

Feel free to adapt the `build-and-push-to-dockerhub.sh` to push to your own repo/registry.

You can add custom plugins in the [Dockerfile](./Dockerfile#L29), just follow the way the Prometheus plugin has been added. 

### Variants
* Main [Dockerfile](Dockerfile) - Debian-based with plugins: Summary and Prometheus
* [Peerswap](peerswap/):
  * Debian-based with plugins: Peerswap, Rebalance, Summary, Prometheus, Paytest
  * Alpine-based with plugins: Peerswap, Rebalance, Summary, Prometheus
* [Historian](historian/) - Debian-based with plugins: Historian, Connection Pool

### Plugins
Add `plugin-dir=/opt/plugins` to your `lightning.conf` to make the custom plugins available.