#!/bin/bash

#bootstrap
REPO_URL="https://github.com/josh56432/killingfloor-docker.git"

# If we are not inside the repository root (missing key files), clone and re-run
if [ ! -f "Dockerfile" ] || [ ! -f "entrypoint.sh" ]; then
    echo "Not in repository root. Cloning from $REPO_URL ..."
    if ! git clone "$REPO_URL"; then
        echo "ERROR: git clone failed. Check REPO_URL and network."
        exit 1
    fi
    cd "killingfloor-docker" || exit 1

    # If running from a pipe, don't re-exec — just continue
    if [ ! -t 0 ] && [ "$0" = "bash" ]; then
        echo "Running from pipe — continuing without re‑execution."
        # Re-run the script from the file we just cloned, but not via exec
        ./build.sh "$@"
        exit $?
    fi

    # Otherwise, re‑exec normally
    if [ -f "$(basename "$0")" ]; then
        exec "$(basename "$0")" "$@"
    elif [ -f "build.sh" ]; then
        exec ./build.sh "$@"
    else
        echo "ERROR: Could not find build script in cloned repo."
        exit 1
    fi
fi

# Detect available container runtimes
HAS_DOCKER=0
HAS_PODMAN=0

command -v docker &>/dev/null && HAS_DOCKER=1
command -v podman &>/dev/null && HAS_PODMAN=1

CONTAINER_CMD=""

if [ $HAS_DOCKER -eq 1 ] && [ $HAS_PODMAN -eq 1 ]; then
    echo "Both Docker and Podman are installed."
    read -p "Which one do you want to use? (docker/podman): " choice
    case "$choice" in
        docker|Docker) CONTAINER_CMD="docker" ;;
        podman|Podman) CONTAINER_CMD="podman" ;;
        *) echo "Invalid choice. Defaulting to docker."; CONTAINER_CMD="docker" ;;
    esac
elif [ $HAS_DOCKER -eq 1 ]; then
    CONTAINER_CMD="docker"
elif [ $HAS_PODMAN -eq 1 ]; then
    CONTAINER_CMD="podman"
else
    echo "ERROR: Neither Docker nor Podman is installed. Please install one of them."
    exit 1
fi

echo ""
echo "Using $CONTAINER_CMD"
echo ""
echo "======================================="
echo "IMPORTANT: Please create a separate steam user to run this server."
echo "======================================="
echo ""
read -p "Target image name (default: kfserver): " IMAGE_NAME
if [ -z "$IMAGE_NAME" ]; then
    IMAGE_NAME="kfserver"
fi
echo ""
read -p "Server steam username: " STEAM_USER
read -sp "Server steam password: " STEAM_PASS
echo

echo "Building with dummy guard code to trigger email..."
$CONTAINER_CMD build \
  --build-arg HOSTUSER="$STEAM_USER" \
  --build-arg HOSTPASS="$STEAM_PASS" \
  --build-arg STEAMGUARD=XXXXX \
  -t "$IMAGE_NAME" .

if [ $? -eq 0 ]; then
  echo "Build succeeded unexpectedly (maybe guard not needed?)"
  exit 0
fi

echo "Steam should have sent a guard code to the email address of the user."
read -p "Enter the Steam Guard code: " GUARD_CODE

cp -r ./addons/System/* ./config/

echo "Rebuilding with correct guard code..."
$CONTAINER_CMD build \
  --build-arg HOSTUSER="$STEAM_USER" \
  --build-arg HOSTPASS="$STEAM_PASS" \
  --build-arg STEAMGUARD="$GUARD_CODE" \
  -t "$IMAGE_NAME" .

echo "Done. Run with: "
echo "$CONTAINER_CMD run --net=host -e ADMINUNAME=username -e ADMINPWD=password ${IMAGE_NAME}"
echo "Where username and password are your desired WebUI username and password."
echo ""
echo "You may also change the port the WebUI is hosted on by passing '-e UIPORT=8075' or any other given port."
echo "To run in background pass -d in the $CONTAINER_CMD command (daemonised)"
echo ""
echo "Container port forwarding is not handled by this program as it was originally developed for kubernetes,"
echo "You can either pass '--net=host' in the $CONTAINER_CMD run command to have it run at the LAN level, or pass the ports individually."
echo "For your sanity the game ports are as follows: -p 7707:7707/udp -p 7708:7708/udp -p 7717:7717/udp -p 8075:8075 -p 20560:20560/udp -p 28852:28852/udp -p 28852:28852"
echo ""
echo "========================="
echo "To tweak config files or install mods refer to the README files in ./addons and ./config"
echo "========================="
echo ""
echo "Thank you for choosing killingfloor-docker for your serving - Josh"
