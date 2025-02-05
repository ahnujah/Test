#!/bin/bash
# start.sh

# Debug mode
set -x

# Check if server.jar exists and is valid
if [ ! -f "server.jar" ] || [ $(stat -f%z "server.jar" 2>/dev/null || stat -c%s "server.jar" 2>/dev/null) -lt 1000 ]; then
    echo "No valid server.jar found. Running installation script..."
    bash install.sh
    if [ ! -f "server.jar" ]; then
        echo "Installation failed! Could not find server.jar"
        exit 1
    fi
fi

# Set default memory if not specified
SERVER_MEMORY=${SERVER_MEMORY:-1024}

# Start the server
echo "Starting server with ${SERVER_MEMORY}MB of RAM..."
java -Xms128M -Xmx${SERVER_MEMORY}M \
    -XX:+UseG1GC \
    -XX:+ParallelRefProcEnabled \
    -XX:MaxGCPauseMillis=200 \
    -XX:+UnlockExperimentalVMOptions \
    -XX:+DisableExplicitGC \
    -XX:+AlwaysPreTouch \
    -XX:G1NewSizePercent=30 \
    -XX:G1MaxNewSizePercent=40 \
    -XX:G1HeapRegionSize=8M \
    -XX:G1ReservePercent=20 \
    -XX:G1HeapWastePercent=5 \
    -XX:G1MixedGCCountTarget=4 \
    -XX:InitiatingHeapOccupancyPercent=15 \
    -XX:G1MixedGCLiveThresholdPercent=90 \
    -XX:G1RSetUpdatingPauseTimePercent=5 \
    -XX:SurvivorRatio=32 \
    -XX:+PerfDisableSharedMem \
    -XX:MaxTenuringThreshold=1 \
    -Dusing.aikars.flags=true \
    -jar server.jar nogui
