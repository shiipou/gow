#!/bin/bash
set -e

source /opt/gow/bash-lib/utils.sh

gow_log "ShadowPC startup.sh"

# Add user to input group for better device support
usermod -a -G input retro 2>/dev/null || true

# Launch ShadowPC through the compositor
source /opt/gow/launch-comp.sh
launcher /usr/bin/shadow-prod
