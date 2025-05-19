FROM rust:latest as builder

RUN apt-get update && apt-get install -y \
    cmake \
    pkg-config \
    libssl-dev \
    libwebsockets-dev \
    libjson-c-dev \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/tsl0922/ttyd.git \
    && cd ttyd \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make \
    && make install

RUN git clone https://github.com/ColtNovak/rmath /rmath
WORKDIR /rmath
RUN cargo build --release

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    libssl3 \
    libwebsockets8 \
    libjson-c5 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /rmath/target/release/rmath /usr/local/bin/rmath
COPY --from=builder /usr/local/bin/ttyd /usr/local/bin/ttyd

WORKDIR /data
EXPOSE 8080

CMD ["ttyd", "-p", "8080", "rmath"]
