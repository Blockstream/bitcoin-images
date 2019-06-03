#!/bin/bash
rm -rf /root/$CERTBOT_TOKEN
/google-cloud-sdk/bin/gsutil rm gs://$GCS_PUBLIC_BUCKET/certs/.well-known/acme-challenge/$CERTBOT_TOKEN
