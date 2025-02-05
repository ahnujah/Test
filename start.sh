#!/bin/bash
# start.sh

# Check if server.jar exists
if [ ! -f "server.jar" ]; then
    echo "No server.jar found. Running installation script..."
    bash install.sh
    if [ ! -f "server.jar" ]; then
        echo "Installation failed! Could not find server.jar"
        exit 1
    fi
fi

# Set default memory if not specified
if [ -z "$SERVER_MEMORY" ]; then
    SERVER_MEMORY=1024
fi

# Start the server with optimized Java flags
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
    -Dusing.aikars.flags=https://mcflags.emc.gs \
    -Daikars.new.flags=true \
    -jar server.jar nogui
