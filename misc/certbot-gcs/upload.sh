#!/bin/bash
echo $CERTBOT_VALIDATION > /root/$CERTBOT_TOKEN

/google-cloud-sdk/bin/gsutil cp /root/$CERTBOT_TOKEN gs://$GCS_PUBLIC_BUCKET/certs/.well-known/acme-challenge/$CERTBOT_TOKEN
