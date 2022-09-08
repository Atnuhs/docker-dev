FROM ubuntu:latest

ENV NONINTERACTIVE=True
ENV TZ=Asia/Tokyo
ENV LANG ja_JP.UTF-8
ENV PATH /home/linuxbrew/.linuxbrew/bin:$PATH
ENV PATH /home/linuxbrew/.linuxbrew/sbin:$PATH

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set apt server at JP server
# Install basic packages for get brew
RUN perl -p -i.bak -e 's%(deb(?:-src|)\s+)https?://(?!archive\.canonical\.com|security\.ubuntu\.com)[^\s]+%$1http://ftp.riken.jp/Linux/ubuntu/%' /etc/apt/sources.list \
    && apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    file \
    git \
    language-pack-ja \
    language-pack-ja-base \
    locales \
    procps \
    wget \
    gosu \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*

# Install brew and bundle
COPY Brewfile /tmp/
RUN mkdir -p /etc/ssl/certs \
    && wget --no-check-certificate http://curl.haxx.se/ca/cacert.pem \
    && mv cacert.pem /etc/ssl/certs/ca-certificates.crt \
    && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
    && brew bundle --file /tmp/Brewfile \
    && brew cleanup -s 

#localeを日本語設定に変更
RUN locale-gen ja_JP.UTF-8

# Install Packer.nvim
RUN git clone --depth 1 https://github.com/wbthomason/packer.nvim \
        ~/.local/share/nvim/site/pack/packer/start/packer.nvim

RUN ghq get https://github.com/Atnuhs/dotfiles.git \
    && ${HOME}/ghq/github.com/Atnuhs/dotfiles/scripts/link.sh

RUN fish -c "curl -sL https://git.io/fisher | source \
    && fisher install jorgebucaran/fisher \
    && fisher install oh-my-fish/theme-bobthefish" \
    && ln -s /home/linuxbrew/.linuxbrew/bin/fish /usr/bin/fish

WORKDIR /root
CMD ["tmux", "-2"]
