FROM ubuntu:latest

ENV NONINTERACTIVE=True

ENV LANG ja_JP.UTF-8
ENV PATH /home/linuxbrew/.linuxbrew/bin:$PATH
ENV PATH /home/linuxbrew/.linuxbrew/sbin:$PATH
ENV DEBIAN_FRONTEND=noninteractive

# Set apt server at JP server
# Install basic packages for get brew
COPY ./files-copy-to-docker/change_apt_server_to_japan /tmp/

RUN /tmp/change_apt_server_to_japan \
    && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    file \
    git \
    language-pack-ja \
    language-pack-ja-base \
    locales \
    procps \
    wget \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*

# Install brew and bundle
COPY ./files-copy-to-docker/install_linuxbrew /tmp/
COPY ./files-copy-to-docker/Brewfile /tmp/

RUN /tmp/install_linuxbrew \
    && brew bundle --file /tmp/Brewfile \
    && brew cleanup -s 

#localeを日本語設定に変更
RUN locale-gen ja_JP.UTF-8

# Install Packer.nvim
COPY ./files-copy-to-docker/install_packer /tmp
RUN /tmp/install_packer

RUN ghq get https://github.com/Atnuhs/dotfiles.git \
    && ${HOME}/ghq/github.com/Atnuhs/dotfiles/scripts/link.sh

COPY ./files-copy-to-docker/install_fisher /tmp

RUN /tmp/install_fisher \
    && fish -c "fisher install oh-my-fish/theme-bobthefish" \
    && ln -s /home/linuxbrew/.linuxbrew/bin/fish /usr/bin/fish

COPY ./files-copy-to-docker/install_docker-compose /tmp
RUN /tmp/install_docker-compose

COPY ./files-copy-to-docker/install_win32yank /tmp
RUN /tmp/install_win32yank

COPY ./files-copy-to-docker /tmp

WORKDIR /root
CMD ["tmux", "-2"]
