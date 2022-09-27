## Lightningd
The Dockerfile was adapted from https://github.com/ElementsProject/lightning/blob/master/Dockerfile.

Feel free to adapt the `build-and-push-to-dockerhub.sh` to push to your own repo/registry.

You can add custom plugins in the [Dockerfile](./Dockerfile#L29), just follow the way the Prometheus plugin has been added. 

### Plugins
Add `plugin-dir=/opt/plugins` to your `lightning.conf` to make the custom plugins available.