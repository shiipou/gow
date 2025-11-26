# syntax=docker/dockerfile:1.4
ARG BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:edge

# hadolint ignore=DL3006
FROM ${BASE_APP_IMAGE}

ARG CORE_PACKAGES=" \
    dbus \
    flatpak \
    "

RUN <<_INSTALL_FLATPAK

set -e
apt-get update
# Install core packages
apt-get install -y --no-install-recommends $CORE_PACKAGES
# Clean
apt-get autoremove -y
apt-get clean
rm -rf \
    /config/.cache \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# Fix bwrap perms for flatpaks
chmod u+s /usr/bin/bwrap
service dbus start
flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

_INSTALL_FLATPAK

COPY --chmod=777 scripts/startup.sh /opt/gow/startup-app.sh

ENV XDG_RUNTIME_DIR=/tmp/.X11-unix

ARG IMAGE_SOURCE
LABEL org.opencontainers.image.source=$IMAGE_SOURCE
