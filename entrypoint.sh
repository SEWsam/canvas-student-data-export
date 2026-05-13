#!/bin/bash

PUID=${PUID:-99}
PGID=${PGID:-100}

if ! getent group "$PGID" >/dev/null 2>&1; then
    groupadd -g "$PGID" exporter
    GROUP_NAME="exporter"
else
    GROUP_NAME=$(getent group "$PGID" | cut -d: -f1)
fi

if ! getent passwd "$PUID" >/dev/null 2>&1; then
    useradd -u "$PUID" -g "$PGID" -d /tmp -m exporter
    USER_NAME="exporter"
else
    USER_NAME=$(getent passwd "$PUID" | cut -d: -f1)
    usermod -d /tmp "$USER_NAME"
fi

chown -R "${USER_NAME}:${GROUP_NAME}" /output /config
 
if [ "$(echo "$VERBOSE" | tr '[:upper:]' '[:lower:]')" = "true" ]; then
    set -- "$@" "--verbose"
fi

export HOME=/tmp

exec gosu "${USER_NAME}:${GROUP_NAME}" "$@"
