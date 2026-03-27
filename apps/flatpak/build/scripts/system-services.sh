#!/bin/sh

mkdir -p /run/dbus

if [ -f /run/dbus/pid ]; then
    if ! kill -0 "$(cat /run/dbus/pid)" >/dev/null 2>&1; then
        echo "*** Removing stale DBus pid file ***"
        rm -f /run/dbus/pid
    fi
fi

if ! pgrep -x dbus-daemon >/dev/null 2>&1; then
    dbus-daemon --system --fork --nosyslog
    echo "*** DBus started ***"
else
    echo "*** DBus already running ***"
fi
