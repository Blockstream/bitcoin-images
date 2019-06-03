#!/bin/bash

/usr/bin/certbot --manual -n -m $EMAIL --agree-tos --manual-auth-hook /usr/local/bin/upload --manual-cleanup-hook /usr/local/bin/clean --domains $DOMAIN --preferred-challenges http --manual-public-ip-logging-ok certonly
/usr/local/bin/finish
