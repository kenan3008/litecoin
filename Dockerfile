FROM debian:bullseye-slim
LABEL authors="Kenan Dervisevic"

ENV DUMB_INIT_VERSION=1.2.5
ENV GOSU_VERSION=1.14
ENV LITECOIN_VERSION=0.18.1
ENV LITECOIN_DATA=/home/litecoin/.litecoin

# create litecoin group and user
# update the packages inside the container and install curl and gnupg
# import gpg keys so that packages can be verified later on
RUN groupadd -g 999 litecoin && \
    useradd -r -u 999 -g litecoin litecoin \
    && apt-get update -y \
    && apt-get install -y curl gnupg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && set -ex \
    && gpg --no-tty --keyserver keyserver.ubuntu.com --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --no-tty --keyserver keyserver.ubuntu.com --recv-keys FE3348877809386C

# Install dumb-init and gosu
# verify validity of the packages
RUN curl -L -s --output /bin/dumb-init "https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_x86_64" && \
    curl -SLO "https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/sha256sums" \
    && grep $(sha256sum /bin/dumb-init | awk '{ print $1 }') sha256sums \
    && chmod +x /bin/dumb-init && \
    mkdir -p /tmp/build && \
    cd /tmp/build && \
    curl -o /usr/local/bin/gosu -fSL https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture) \
    && curl -o /usr/local/bin/gosu.asc -fSL https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture).asc \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu

# install litecoin binary and verify its gpg and sha checksum
# cleanup apt-get packages and cache
RUN curl -SLO https://download.litecoin.org/litecoin-${LITECOIN_VERSION}/linux/litecoin-${LITECOIN_VERSION}-x86_64-linux-gnu.tar.gz \
    && curl -SLO https://download.litecoin.org/litecoin-${LITECOIN_VERSION}/linux/litecoin-${LITECOIN_VERSION}-linux-signatures.asc \
    && gpg --verify litecoin-${LITECOIN_VERSION}-linux-signatures.asc \
    && grep $(sha256sum litecoin-${LITECOIN_VERSION}-x86_64-linux-gnu.tar.gz | awk '{ print $1 }') litecoin-${LITECOIN_VERSION}-linux-signatures.asc \
    && tar --strip=2 -xzf *.tar.gz -C /usr/local/bin \
    && rm *.tar.gz \
    && apt-get remove -y curl gnupg \
    && apt-get auto-remove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME ["/home/litecoin/.litecoin"]

EXPOSE 9332 9333

CMD ["litecoind"]
