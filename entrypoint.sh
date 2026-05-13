#!/bin/bash

PUID=${PUID:-99}
PGID=${PGID:-100}

# Create or find the group
if ! getent group "$PGID" >/dev/null 2>&1; then
    groupadd -g "$PGID" canvasgroup
    GROUP_NAME="canvasgroup"
else
    GROUP_NAME=$(getent group "$PGID" | cut -d: -f1)
fi

# Create or find the user, and FORCE their home directory to /tmp
if ! getent passwd "$PUID" >/dev/null 2>&1; then
    useradd -u "$PUID" -g "$PGID" -d /tmp -m canvasuser
    USER_NAME="canvasuser"
else
    USER_NAME=$(getent passwd "$PUID" | cut -d: -f1)
    # If the user already exists (like Unraid's 99/nobody), change their home directory to /tmp
    usermod -d /tmp "$USER_NAME"
fi

chown -R "${USER_NAME}:${GROUP_NAME}" /output /config
 
if [ "$(echo "$VERBOSE" | tr '[:upper:]' '[:lower:]')" = "true" ]; then
    set -- "$@" "--verbose"
fi

# Ensure the environment variable is also set for child processes
export HOME=/tmp

exec gosu "${USER_NAME}:${GROUP_NAME}" "$@"
