FROM debian:bookworm-slim

ARG WATERFALLS_VERSION
ENV WATERFALLS_VERSION=$WATERFALLS_VERSION

RUN apt update
RUN apt install -qfy curl

RUN curl -Ls https://github.com/LeoComandini/waterfalls/releases/download/${WATERFALLS_VERSION}/waterfalls_${WATERFALLS_VERSION}.gz | gunzip > waterfalls
RUN chmod +x waterfalls

RUN apt remove -yf curl
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["./waterfalls"]