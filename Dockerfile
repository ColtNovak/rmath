FROM archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
    base-devel \
    git \
    sudo \
    ncurses \
    tmux \
    expect

RUN useradd -m builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder

USER builder
WORKDIR /home/builder

RUN git clone https://aur.archlinux.org/yay.git && \
    cd yay && \
    makepkg -si --noconfirm

RUN yay -S --noconfirm rmath

USER root

RUN pacman -S --noconfirm \
    cmake \
    pkg-config \
    openssl \
    json-c \
    libwebsockets \
    bash \
    util-linux && \  # For stty and terminal tools
    git clone https://github.com/tsl0922/ttyd.git && \
    cd ttyd && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make && \
    make install

RUN pacman -Scc --noconfirm && \
    rm -rf /home/builder/yay /var/cache/pacman/pkg/*

WORKDIR /data
EXPOSE 8080

CMD ["ttyd", "-t", "-p", "8080", "bash", "-ic", "stty sane && TERM=xterm-256color rmath"]
