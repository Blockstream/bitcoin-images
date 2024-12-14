FROM debian:bookworm-slim

ARG ELECTRSD_VERSION
ENV ELECTRSD_VERSION=$ELECTRSD_VERSION

RUN useradd -s /bin/bash -u 2000 electrsd

RUN apt update
RUN apt install -qfy curl
RUN mkdir -p /home/electrsd && chown -R electrsd:electrsd /home/electrsd

WORKDIR /home/electrsd
RUN curl -Ls https://github.com/RCasatta/electrsd/releases/download/electrs_releases/electrs_linux_esplora_${ELECTRSD_VERSION}_liquid.gz | gunzip > electrs
RUN chmod +x electrs

RUN apt remove -yf curl
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER electrsd
ENTRYPOINT ["./electrs"]