#!/bin/bash
/google-cloud-sdk/bin/gsutil -m cp -r gs://$GCS_PRIVATE_BUCKET/letsencrypt.tar.gz /root/letsencrypt.tar.gz
/bin/tar -pxvzf /root/letsencrypt.tar.gz -C /
