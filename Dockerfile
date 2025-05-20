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
    && cmake -DCMAKE_BUILD_TYPE=Release -Dstatic=ON .. \
    && make \
    && make install

WORKDIR /rmath
RUN cargo build --release

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    libssl3 \
    libjson-c5 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /rmath/target/release/rmath /usr/local/bin/
COPY --from=builder /usr/local/bin/ttyd /usr/local/bin/

WORKDIR /data
EXPOSE 8080

CMD ["ttyd", "-p", "8080", "rmath"]
