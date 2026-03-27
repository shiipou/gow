#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

gow_log "ShadowPC startup.sh"

# VA-API setup: auto-detect GPU if LIBVA_DRIVER_NAME is not set
if [ -z "$LIBVA_DRIVER_NAME" ]; then
    if [ -e /dev/nvidia0 ]; then
        export LIBVA_DRIVER_NAME=nvidia
        export NVD_BACKEND=${NVD_BACKEND:-direct}
        gow_log "Detected NVIDIA GPU, using VA-API driver: nvidia"
    else
        gow_log "Using default VA-API driver (auto-detect for Intel/AMD)"
    fi
else
    gow_log "Using user-specified VA-API driver: $LIBVA_DRIVER_NAME"
fi

# Register shadow:// protocol handler
xdg-mime default shadow-client-preprod.desktop x-scheme-handler/tech.shadow.preprod

# Launch ShadowPC through the compositor
source /opt/gow/launch-comp.sh
launcher /usr/bin/shadow-beta --no-sandbox
