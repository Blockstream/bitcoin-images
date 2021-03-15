## Lightningd
The Dockerfile was adapted from https://github.com/ElementsProject/lightning/blob/master/Dockerfile.

Feel free to adapt the `build-and-push-to-dockerhub.sh` to push to your own repo/registry.

You can add custom plugins in the [Dockerfile](./Dockerfile#L29), just follow the way the Prometheus plugin has been added. 

### Building armv7
You need to: `sudo apt-get install -y qemu-user-static` and copy it in this directory first.
```
48d68c1258465bc0d9e957d9dbe0f8321f7b33436619501f19b1c430b807e69a  qemu-arm-static
```

### Plugins
Add `plugin-dir=/usr/local/libexec/c-lightning/plugins` to your lightning.conf to make the custom plugins available