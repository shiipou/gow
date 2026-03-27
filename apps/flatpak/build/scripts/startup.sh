#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

gow_log "Flatpak startup.sh"

export XDG_DATA_DIRS=/var/lib/flatpak/exports/share:/home/retro/.local/share/flatpak/exports/share:/usr/local/share/:/usr/share/

if [ -z "$XDG_RUNTIME_DIR" ] || [ "$XDG_RUNTIME_DIR" = "/tmp" ]; then
    export XDG_RUNTIME_DIR="/tmp/runtime-$USER"
fi
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

if [ -z "$FLATPAK_APP_ID" ]; then
    gow_log "ERROR: FLATPAK_APP_ID environment variable is not set."
    gow_log "Please set FLATPAK_APP_ID to the flatpak app ID you want to run (e.g., org.videolan.VLC)"
    exit 1
fi

gow_log "Ensuring flathub remote is available for the user"
dbus-run-session -- flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true

if [ -n "$FLATPAK_REPO_URL" ]; then
    REPO_NAME=${FLATPAK_REPO_NAME:-"custom"}
    gow_log "Adding custom flatpak repository: $REPO_NAME from $FLATPAK_REPO_URL"
    dbus-run-session -- flatpak remote-add --user --if-not-exists "$REPO_NAME" "$FLATPAK_REPO_URL" || true
fi

gow_log "Ensuring $FLATPAK_APP_ID is fully installed and up to date..."
REMOTE_ARGS=()
if [ -n "$FLATPAK_REPO_URL" ]; then
    REMOTE_ARGS+=("$REPO_NAME")
fi

dbus-run-session -- flatpak install -y --noninteractive --user --or-update ${REMOTE_ARGS[@]+"${REMOTE_ARGS[@]}"} "$FLATPAK_APP_ID"
dbus-run-session -- flatpak override --user "$FLATPAK_APP_ID" --filesystem=home

gow_log "Starting $FLATPAK_APP_ID"

source /opt/gow/launch-comp.sh

launcher flatpak run $FLATPAK_STARTUP_FLAGS "$FLATPAK_APP_ID"
