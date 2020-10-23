## Tor Hidden Service
The default `torrc` file is copied into the image, so feel free to change before building/using this image.
Feel free to adapt the `build-and-push-to-dockerhub.sh` to push to your own repo/registry.

### How to run
The `torrc` file that's included has some minor modifications from the default torrc file.

### Building armv7
You need to: `sudo apt-get install -y qemu-user-static` and copy it in this directoy first.

