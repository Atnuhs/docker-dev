FROM ubuntu:latest

# Set noninteractive variables for non-interactive install of brew
ENV NONINTERACTIVE=True

# Set time zone for apt-get tzdata non-interactive
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set apt server at JP server
RUN perl -p -i.bak -e 's%(deb(?:-src|)\s+)https?://(?!archive\.canonical\.com|security\.ubuntu\.com)[^\s]+%$1http://ftp.riken.jp/Linux/ubuntu/%' /etc/apt/sources.list 

# Redy for install of brew
RUN apt-get update && apt-get install -y --no-install-recommends \
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

#localeを日本語設定に変更
RUN locale-gen ja_JP.UTF-8

#言語を日本語に設定
ENV LANG ja_JP.UTF-8

# Install brew
RUN mkdir -p /etc/ssl/certs && \
    wget --no-check-certificate http://curl.haxx.se/ca/cacert.pem && \
    mv cacert.pem /etc/ssl/certs/ca-certificates.crt && \
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Path of brew packages
ENV PATH /home/linuxbrew/.linuxbrew/bin:$PATH
ENV PATH /home/linuxbrew/.linuxbrew/sbin:$PATH

# Install packages for write code
COPY Brewfile /tmp/
RUN brew bundle --file /tmp/Brewfile \
    && brew cleanup -s

# Install Packer.nvim
RUN git clone --depth 1 https://github.com/wbthomason/packer.nvim \
        ~/.local/share/nvim/site/pack/packer/start/packer.nvim

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
