#!/bin/bash

mkdir -p /root/.steam 2>&1

if [ -z "$SKIP_UPDATE" ] || [ ! -f "/server/bin/AvorionServer" ]; then
    if [ -n "$SKIP_UPDATE" ] && [ ! -f "/server/bin/AvorionServer" ]; then
        echo "[entrypoint] SKIP_UPDATE is set but server files are missing. Forcing update..."
    fi
    echo "[entrypoint] Updating Avorion Dedicated Server files with steamcmd..."
    /usr/bin/steamcmd +force_install_dir "/server" +login anonymous +app_update 565060 validate +quit
    [ $? -ne 0 ] && [ -z "${IGNORE_UPDATE_FAILURE:-}" ] && exit 1
else
    echo "[entrypoint] Skipping update as SKIP_UPDATE is set"
fi

echo "[entrypoint] Starting Avorion Dedicated Server..."
cd /server
exec env LD_LIBRARY_PATH=/server/linux64 /server/bin/AvorionServer $SERVER_ARGS 2>&1
