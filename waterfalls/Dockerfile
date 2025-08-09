FROM rust:1.81.0 as builder
RUN apt-get update && apt-get install -y clang git

ARG WATERFALLS_REPO=https://github.com/RCasatta/waterfalls
ENV WATERFALLS_REPO=$WATERFALLS_REPO
ARG WATERFALLS_COMMIT_HASH=master
ENV WATERFALLS_COMMIT_HASH=$WATERFALLS_COMMIT_HASH

WORKDIR /
RUN git clone --no-checkout $WATERFALLS_REPO \
 && cd waterfalls \
 && git checkout $WATERFALLS_COMMIT_HASH
WORKDIR /waterfalls

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    cargo build --release

FROM debian:stable-slim
RUN apt-get update && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*
COPY --from=builder /waterfalls/target/release/waterfalls /usr/local/bin/waterfalls
ENTRYPOINT [ "waterfalls" ]