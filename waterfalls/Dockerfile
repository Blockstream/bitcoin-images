FROM debian:bookworm-slim

ARG WATERFALLS_VERSION
ENV WATERFALLS_VERSION=$WATERFALLS_VERSION

RUN useradd -s /bin/bash -u 2000 waterfalls

RUN apt update
RUN apt install -qfy curl
RUN mkdir -p /home/waterfalls && chown -R waterfalls:waterfalls /home/waterfalls

WORKDIR /home/waterfalls
RUN curl -Ls https://github.com/LeoComandini/waterfalls/releases/download/${WATERFALLS_VERSION}/waterfalls_${WATERFALLS_VERSION}.gz | gunzip > waterfalls_${WATERFALLS_VERSION}
RUN chmod +x waterfalls_$WATERFALLS_VERSION
RUN mv waterfalls_$WATERFALLS_VERSION waterfalls

RUN apt remove -yf curl
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER waterfalls
ENTRYPOINT ["./waterfalls"]