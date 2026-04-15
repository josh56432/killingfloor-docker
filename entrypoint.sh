#!/bin/bash
set -e

SERVER_ROOT="/home/steam/server"
SYSTEM_DIR="$SERVER_ROOT/System"
INI="$SYSTEM_DIR/KillingFloor.ini"
PORT=${UIPORT:-8075}        # default
USER="${ADMINUNAME:-admin}"
PASS="${ADMINPWD:-changeme}"
CUSTOM_CONFIG_DIR="/home/steam/custom_config"

export LD_LIBRARY_PATH=/home/steam/.local/share/Steam/steamcmd/linux32
cd "$SYSTEM_DIR"

# Launch bare server to generate ini file
if [ ! -f "$INI" ]; then
    echo "[+] KillingFloor.ini not found — generating via bare server boot..."

    ./ucc-bin server KF-BioticsLab?game=KFmod.KFGameType -nohomedir &
    UCC_PID=$!

    # Give UE2 time to write config files
     echo "[+] Waiting for KillingFloor.ini to be generated..."
    while [ ! -f "$INI" ]; do
        sleep 1
    done

    # Extra wait to ensure file is fully written
    echo "[+] KillingFloor.ini found"
    sleep 5

    echo "[+] Stopping bootstrap server (PID $UCC_PID)"
    kill "$UCC_PID"
    wait "$UCC_PID" 2>/dev/null || true
fi


if [ -d "$CUSTOM_CONFIG_DIR" ]; then
    echo "[+] Copying custom config files from $CUSTOM_CONFIG_DIR to $SYSTEM_DIR"

    cp -rf "$CUSTOM_CONFIG_DIR/"* "$SYSTEM_DIR/" 2>/dev/null || true

    echo "[+] Custom config files applied."
else
    echo "[!] Custom config directory $CUSTOM_CONFIG_DIR not found – skipping."
fi

# Admin access
if grep -q "^\[Engine.AccessControl\]" "$INI"; then
    sed -i "/^\[Engine.AccessControl\]/,/^\[/{s/^AdminPassword=.*/AdminPassword=${PASS}/}" "$INI"
else
    cat >> "$INI" <<EOF

[Engine.AccessControl]
AdminPassword=${PASS}
EOF
fi

# Force enable web admin through ini file sed
echo "[+] Ensuring WebAdmin is enabled..."

# WebAdmin section
if grep -q "^\[UWeb.WebServer\]" "$INI"; then
    sed -i '/^\[UWeb.WebServer\]/,/^\[/{s/^bEnabled=.*/bEnabled=True/}' "$INI"
    sed -i "/^\[UWeb.WebServer\]/,/^\[/{s/^ListenPort=.*/ListenPort=${PORT}/}" "$INI"
else
    cat >> "$INI" <<EOF

[UWeb.WebServer]
bEnabled=True
ListenPort=${PORT}
EOF
fi



echo "[+] Starting Killing Floor server..."

exec ./ucc-bin server \
  "KF-westlondon.rom?game=KFmod.KFGameType?VACSecured=true?MaxPlayers=6?GameLength=2?AdminName=${USER}?AdminPassword=${PASS}" \
  -nohomedir
