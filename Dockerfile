FROM archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
    base-devel \
    git \
    sudo \
    ncurses \
    bash

RUN useradd -m builder && \
    echo "builder ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder && \
    chmod 0440 /etc/sudoers.d/builder

USER builder
WORKDIR /home/builder

RUN git clone https://aur.archlinux.org/yay.git && \
    cd yay && \
    makepkg -si --noconfirm --skippgpcheck && \
    cd .. && \
    rm -rf yay

RUN yay -S --noconfirm rmath --overwrite='*' --nocheck && \
    sudo pacman -Syu --noconfirm && \
    sudo cp -v $(which rmath) /usr/local/bin/rmath

USER root

RUN ls -lh /usr/local/bin/rmath && \
    ldd /usr/local/bin/rmath && \
    echo "rmath version: $(rmath --version)"

RUN pacman -S --noconfirm \
    cmake \
    pkg-config \
    openssl \
    json-c \
    libwebsockets

RUN git clone https://github.com/tsl0922/ttyd.git && \
    cd ttyd && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make && \
    make install

RUN pacman -Scc --noconfirm && \
    rm -rf /var/cache/pacman/pkg/* /home/builder/.cache/*

WORKDIR /data
EXPOSE 8080

CMD ["ttyd", "-t", "rendererType=canvas", "-p", "8080", "bash", "-c", "rmath"]
