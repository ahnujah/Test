#!/bin/bash
# start.sh

# ANSI color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# Function to display animated text
animate_text() {
    text="$1"
    color="$2"
    for (( i=0; i<${#text}; i++ )); do
        echo -ne "${color}${text:$i:1}${NC}"
        sleep 0.01
    done
    echo
}

# Clear screen and show banner
clear
echo -e "${CYAN}${BOLD}"
cat << "EOF"
 ██████╗███████╗ █████╗ ██████╗  █████╗  ██████╗████████╗██╗   ██╗██╗     
██╔════╝╚══███╔╝██╔══██╗██╔══██╗██╔══██╗██╔════╝╚══██╔══╝╚██╗ ██╔╝██║     
██║       ███╔╝ ███████║██████╔╝███████║██║        ██║    ╚████╔╝ ██║     
██║      ███╔╝  ██╔══██║██╔══██╗██╔══██║██║        ██║     ╚██╔╝  ██║     
╚██████╗███████╗██║  ██║██║  ██║██║  ██║╚██████╗   ██║      ██║   ███████╗
 ╚═════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝   ╚═╝      ╚═╝   ╚══════╝
EOF
echo -e "${NC}"

animate_text "Czaractyl Server Startup" "${YELLOW}${BOLD}"
echo -e "${MAGENTA}${BOLD}==========================================================================${NC}"

# Check if server.jar exists and is valid
if [ ! -f "server.jar" ] || [ $(stat -f%z "server.jar" 2>/dev/null || stat -c%s "server.jar" 2>/dev/null) -lt 1000000 ]; then
    animate_text "No valid server.jar found. Running installation script..." "${YELLOW}${BOLD}"
    bash install.sh
    if [ ! -f "server.jar" ]; then
        animate_text "Installation failed! Could not find server.jar" "${RED}${BOLD}"
        exit 1
    fi
fi

# Set default memory if not specified or if it's 0
if [ -z "$SERVER_MEMORY" ] || [ "$SERVER_MEMORY" -eq 0 ]; then
    SERVER_MEMORY=1024
    animate_text "SERVER_MEMORY was not set or was 0. Using default value of 1024MB." "${YELLOW}${BOLD}"
fi

# Create automatic backup directory
mkdir -p backups

# Perform automatic backup
backup_name="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
animate_text "Creating automatic backup..." "${CYAN}"
tar -czf "backups/$backup_name" world world_nether world_the_end

# Create startup script with optimized flags
animate_text "Starting server with ${SERVER_MEMORY}MB of RAM..." "${GREEN}${BOLD}"

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
    JAVA_FLAGS="-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 
