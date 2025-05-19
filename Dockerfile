FROM rust:latest as builder

RUN apt-get update && apt-get install -y \
    cmake \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/ColtNovak/rmath /app
WORKDIR /app

RUN cargo build --release

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    libssl3 \
    ttyd \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/target/release/rmath /usr/local/bin/rmath

WORKDIR /app
EXPOSE 8080

CMD ["ttyd", "-p", "8080", "rmath"]
