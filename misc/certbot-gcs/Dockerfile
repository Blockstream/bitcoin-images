FROM google/cloud-sdk:alpine

RUN apk add --update certbot bash openssl

COPY upload.sh /usr/local/bin/upload
COPY clean.sh /usr/local/bin/clean
COPY finish.sh /usr/local/bin/finish
COPY download.sh /usr/local/bin/download
COPY renew.sh /usr/local/bin/renew
RUN chmod +x /usr/local/bin/upload && \
    chmod +x /usr/local/bin/clean && \
    chmod +x /usr/local/bin/finish && \
    chmod +x /usr/local/bin/download && \
    chmod +x /usr/local/bin/renew
