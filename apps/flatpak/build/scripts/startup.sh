#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

gow_log "Flatpak startup.sh"

export XDG_DATA_DIRS=/var/lib/flatpak/exports/share:/home/retro/.local/share/flatpak/exports/share:/usr/local/share/:/usr/share/

# FLATPAK_APP_ID is required - the flatpak app ID to install and run (e.g., "org.videolan.VLC")
if [ -z "$FLATPAK_APP_ID" ]; then
    gow_log "ERROR: FLATPAK_APP_ID environment variable is not set."
    gow_log "Please set FLATPAK_APP_ID to the flatpak app ID you want to run (e.g., org.videolan.VLC)"
    exit 1
fi

# Optional: FLATPAK_REPO_URL for custom flatpak repository (.flatpakrepo file URL)
#           Default: https://flathub.org/repo/flathub.flatpakrepo
# Optional: FLATPAK_REPO_NAME for custom repository name (defaults to "custom")

# Set default repo URL to Flathub if not specified
FLATPAK_REPO_URL=${FLATPAK_REPO_URL:-"https://flathub.org/repo/flathub.flatpakrepo"}
REPO_NAME=${FLATPAK_REPO_NAME:-"custom"}

# Add repository (uses --from for .flatpakrepo files)
gow_log "Adding flatpak repository: $REPO_NAME from $FLATPAK_REPO_URL"
if [[ "$FLATPAK_REPO_URL" == *.flatpakrepo ]]; then
    flatpak remote-add --system --if-not-exists "$REPO_NAME" --from "$FLATPAK_REPO_URL" || true
else
    flatpak remote-add --system --if-not-exists "$REPO_NAME" "$FLATPAK_REPO_URL" || true
fi

# Install the flatpak app if not already installed
gow_log "Checking if $FLATPAK_APP_ID is installed..."
if ! flatpak list --system --app --columns=application | grep -qx "$FLATPAK_APP_ID"; then
    gow_log "Installing $FLATPAK_APP_ID from $REPO_NAME..."
    flatpak install -y --noninteractive --system "$REPO_NAME" "$FLATPAK_APP_ID"
    flatpak override --system "$FLATPAK_APP_ID" --filesystem=home
else
    gow_log "$FLATPAK_APP_ID is already installed."
    # Update the app if already installed
    gow_log "Checking for updates..."
    flatpak update -y --noninteractive --system "$FLATPAK_APP_ID" || true
fi

gow_log "Starting $FLATPAK_APP_ID"
source /opt/gow/launch-comp.sh
# shellcheck disable=SC2086
launcher flatpak run $FLATPAK_STARTUP_FLAGS "$FLATPAK_APP_ID"
