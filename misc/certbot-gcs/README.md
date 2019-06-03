### GCloud SDK, certbot
This is a useful CI/CD docker image that has both tools installed - `gcloud` CLI, `certbot`, using Google Cloud Storage to store a `tar`-d SSL server certs directory.

#### How to use
* Run `download.sh` once as a `systemd` oneshot service into mounted volume (`/etc/letsencrypt`) from underlying host to get certs from GCS
* Run `renew.sh` as a `timer.service`  with the same mount (`/etc/letsencrypt`) to renew certs and upload the renewed cert to GCS

```
$ ./build-and-push-to-dockerhub.sh
```
