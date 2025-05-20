FROM archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
    base-devel \
    git \
    sudo \
    ncurses \
    bash \
    procps-ng \
    vim \
    tmux \
    expect

RUN useradd -m builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder

USER builder
WORKDIR /home/builder

RUN git clone https://aur.archlinux.org/yay.git && \
    cd yay && \
    sed -i 's/-j2/-j1/' PKGBUILD && \
    MAKEFLAGS="-j1" makepkg -si --noconfirm

RUN yay -S --noconfirm rmath-debug

USER root

RUN pacman -S --noconfirm \
    cmake \
    pkg-config \
    openssl \
    json-c \
    libwebsockets && \
    git clone --depth 1 https://github.com/tsl0922/ttyd.git && \
    cd ttyd && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Debug .. && \
    make && \
    make install

RUN pacman -Scc --noconfirm && \
    rm -rf /home/builder/yay /var/cache/pacman/pkg/*

WORKDIR /data

EXPOSE 8080

 CMD ["ttyd", "-t", "rendererType=dom", "-p", "8080", "tmux", "new-session", "rmath"]
