## Stage 1: Fetch the latest version and determine the architecture
FROM debian:stable-slim@sha256:8f0c555de6a2f9c2bda1b170b67479d11f7f5e3b66bb4a7a1d8843361c9dd3ff AS fetcher

ENV LATEST_ENDPOINT=https://api.github.com/repos/meilisearch/meilisearch/releases/latest

SHELL ["/bin/bash", "-c"]

# Install necessary packages
RUN apt update; apt install -y curl jq wget

# Fetch the latest version and set architecture
RUN LATEST_VERSION=$(curl -sX GET $LATEST_ENDPOINT | jq --raw-output '.tag_name' | sed 's/^v//') && \
    UNAME_ARCH=$(uname -m) && \
    if [ "$UNAME_ARCH" = "x86_64" ]; then ARCH="amd64"; \
    elif [ "$UNAME_ARCH" = "aarch64" ]; then ARCH="aarch64"; \
    else echo "Unsupported architecture: $UNAME_ARCH" && exit 1; fi && \
    echo "VERSION=$LATEST_VERSION" > /tmp/version_info && \
    echo "ARCH=$ARCH" >> /tmp/version_info

# Source the version and architecture info and download node
RUN source /tmp/version_info && \
    wget -O /tmp/meilisearch https://github.com/meilisearch/meilisearch/releases/download/v${VERSION}/meilisearch-linux-${ARCH} && \
    chmod +x /tmp/meilisearch

## Stage 2: Install node
FROM debian:stable-slim@sha256:8f0c555de6a2f9c2bda1b170b67479d11f7f5e3b66bb4a7a1d8843361c9dd3ff

ENV HOME=/data

# Install wget
RUN apt update && \
    mkdir ${HOME} && \
    useradd user -m

# Copy the version and architecture info from the fetcher stage
COPY --from=fetcher /tmp/version_info /tmp/version_info
COPY --from=fetcher /tmp/meilisearch /usr/bin/meilisearch

# Setup permission
RUN chown -R user:user ${HOME}

WORKDIR ${HOME}

USER user

EXPOSE 7700

CMD [ "meilisearch"]