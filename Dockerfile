FROM archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm base-devel git sudo ncurses bash util-linux && \
    rm -rf /var/cache/pacman/pkg/*

RUN curl -L https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 -o /usr/bin/ttyd && \
    chmod +x /usr/bin/ttyd

RUN useradd -m builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder

USER builder
RUN git clone https://aur.archlinux.org/yay.git /tmp/yay && \
    cd /tmp/yay && \
    makepkg -si --noconfirm --skippgpcheck && \
    rm -rf /tmp/yay

RUN yay -S --noconfirm rmath --overwrite='*' --nocheck && \
    sudo cp -v $(which rmath) /usr/local/bin/

USER root
RUN ln -s /usr/share/terminfo /etc/terminfo

WORKDIR /data
EXPOSE 8080

CMD ["ttyd", "-w", "-t", "rendererType=canvas", "-p", "8080", "bash", "--login", "-ic", "TERM=xterm-256color; stty sane; rmath"]
