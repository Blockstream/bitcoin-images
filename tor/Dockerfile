FROM debian:bookworm-slim

RUN useradd -s /bin/bash -u 2000 tor
RUN mkdir -p /var/run/tor && chown -R tor:tor /var/run/tor && chmod 2700 /var/run/tor
RUN mkdir -p /home/tor/tor && chown -R tor:tor /home/tor/tor  && chmod 2700 /home/tor/tor

ARG VER
ENV VER=$VER
RUN apt update && apt install -qfy tor=${VER}

COPY ./torrc /home/tor/tor/torrc

USER tor
