#!/bin/bash
# start.sh

# ANSI color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'

# Check if server.jar exists and is valid
if [ ! -f "server.jar" ] || [ $(stat -f%z "server.jar" 2>/dev/null || stat -c%s "server.jar" 2>/dev/null) -lt 1000000 ]; then
    echo -e "${YELLOW}${BOLD}No valid server.jar found. Running installation script...${NC}"
    bash install.sh
    if [ ! -f "server.jar" ]; then
        echo -e "${RED}${BOLD}Installation failed! Could not find server.jar${NC}"
        exit 1
    fi
fi

# Set default memory if not specified or if it's 0
if [ -z "$SERVER_MEMORY" ] || [ "$SERVER_MEMORY" -eq 0 ]; then
    SERVER_MEMORY=1024
    echo -e "${YELLOW}${BOLD}SERVER_MEMORY was not set or was 0. Using default value of 1024MB.${NC}"
fi

# Create automatic backup directory
mkdir -p backups

# Create startup script with optimized flags
echo -e "${GREEN}${BOLD}Starting server with ${SERVER_MEMORY}MB of RAM...${NC}"

# Different optimization flags based on server memory
if [ $SERVER_MEMORY -ge 12000 ]; then
    # High memory optimization (12GB+)
    JAVA_FLAGS="-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 \
    -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch \
    -XX:G1NewSizePercent=40 -XX:G1MaxNewSizePercent=50 -XX:G1HeapRegionSize=16M \
    -XX:G1ReservePercent=15 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 \
    -XX:InitiatingHeapOccupancyPercent=20 -XX:G1MixedGCLiveThresholdPercent=90 \
    -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem \
    -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=true -Daikars.new.flags=true \
    -XX:+UseNUMA -XX:+UseStringDeduplication"
elif [ $SERVER_MEMORY -ge 6000 ]; then
    # Medium memory optimization (6-12GB)
    JAVA_FLAGS="-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 \
    -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch \
    -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M \
    -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 \
    -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 \
    -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem \
    -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=true"
else
    # Low memory optimization (<6GB)
    JAVA_FLAGS="-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 \
    -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:G1NewSizePercent=20 \
    -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=4M \
    -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90"
fi

# Execute server with appropriate flags
exec java -Xms${SERVER_MEMORY}M -Xmx${SERVER_MEMORY}M $JAVA_FLAGS \
    -XX:+UseCompressedOops \
    -jar server.jar nogui

# Note: The exec command ensures proper signal handling
