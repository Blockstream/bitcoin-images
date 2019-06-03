#!/bin/bash

mkdir -p /etc/letsencrypt/certs
if [ -f /etc/letsencrypt/certs/dhparam.pem ]; then
   echo "Not regenerating dhparam.pem, already exists."
else
   /usr/bin/openssl dhparam -dsaparam -out /etc/letsencrypt/certs/dhparam.pem 4096
fi

/bin/tar -pcvzf /root/letsencrypt.tar.gz /etc/letsencrypt
/google-cloud-sdk/bin/gsutil -m cp -r /root/letsencrypt.tar.gz gs://$GCS_PRIVATE_BUCKET/letsencrypt.tar.gz
