# syntax=docker/dockerfile:1.4
ARG BASE_APP_IMAGE

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
ARG REQUIRED_PACKAGES=" \
    wget \
    gpg \
    libva-glx2 \
    libvdpau1 \
    libva-drm2 \
    libcurl4 \
    libva-wayland2 \
"

# Install ShadowPC
RUN <<_INSTALL_PACKAGES
apt-get update
apt-get install -y --no-install-recommends $REQUIRED_PACKAGES
wget -qO- https://repository.shadow.tech/shadow_signing.key | gpg --dearmor > /tmp/packages.shadowapp.gpg
install -o root -g root -m 644 /tmp/packages.shadowapp.gpg /etc/apt/trusted.gpg.d/
echo "deb [arch=amd64] https://repository.shadow.tech/prod bullseye main" > /etc/apt/sources.list.d/shadow-prod.list
rm -f /tmp/packages.shadowapp.gpg
apt-get update
apt-get install -y --no-install-recommends shadow-prod
apt-get autoremove -y
rm -rf /var/lib/apt/lists/*
_INSTALL_PACKAGES

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
