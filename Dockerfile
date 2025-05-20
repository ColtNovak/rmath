FROM archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
    base-devel git sudo ncurses bash-completion util-linux

RUN curl -L https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 -o /usr/bin/ttyd \
    && chmod +x /usr/bin/ttyd

RUN useradd -m builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder

USER builder
RUN git clone https://aur.archlinux.org/yay.git /tmp/yay && \
    cd /tmp/yay && \
    makepkg -si --noconfirm --skippgpcheck

RUN yay -S --noconfirm rmath

USER root

RUN cp -v $(which rmath) /usr/local/bin/

WORKDIR /data
EXPOSE 8080

CMD ["ttyd", "-p", "8080", "bash", "-ic", "TERM=xterm-256color rmath"]
