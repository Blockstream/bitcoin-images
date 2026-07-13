# Tor Hidden Service

The default `torrc` file is copied into the image, so feel free to change before building/using this image.
Feel free to adapt the `build-and-push-to-dockerhub.sh` to push to your own repo/registry.

The build verifies Tor's signed upstream checksum and pins the release tarball
checksum in the Dockerfile. It publishes an explicit version tag only; runtime
consumers should pin that tag by digest rather than use `latest`.

## How to run

The `torrc` file that's included has some minor modifications from the default torrc file.
