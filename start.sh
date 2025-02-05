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
    echo -e "${color}${text}${NC}"
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
echo -e "${YELLOW}${BOLD}Developed & Maintained By @arpit_singh_boy${NC}"

animate_text "Czaractyl Server Startup" "${YELLOW}${BOLD}"
echo -e "${MAGENTA}${BOLD}==========================================================================${NC}"

# Detect server type
if [ -f "bedrock_server" ]; then
    SERVER_TYPE="bedrock"
elif [ -f "bungeecord.jar" ]; then
    SERVER_TYPE="bungeecord"
else
    SERVER_TYPE="java"
fi

# Check if server files exist
if [ "$SERVER_TYPE" = "bedrock" ] && [ ! -f "bedrock_server" ]; then
    animate_text "No valid server files found. Running installation script..." "${YELLOW}${BOLD}"
    bash install.sh
    if [ ! -f "bedrock_server" ]; then
        animate_text "Installation failed! Could not find server files" "${RED}${BOLD}"
        exit 1
    fi
elif [ "$SERVER_TYPE" != "bedrock" ] && [ ! -f "server.jar" ]; then
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
if [ "$SERVER_TYPE" != "bedrock" ] && [ "$SERVER_TYPE" != "bungeecord" ]; then
    backup_name="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    animate_text "Creating automatic backup..." "${CYAN}"
    tar -czf "backups/$backup_name" world world_nether world_the_end
fi

# Function to start the server
start_server() {
    animate_text "Starting server with ${SERVER_MEMORY}MB of RAM..." "${GREEN}${BOLD}"

    if [ "$SERVER_TYPE" = "bedrock" ]; then
        animate_text "Starting Bedrock server..." "${GREEN}${BOLD}"
        LD_LIBRARY_PATH=. ./bedrock_server &
    elif [ "$SERVER_TYPE" = "bungeecord" ]; then
        animate_text "Starting BungeeCord server..." "${GREEN}${BOLD}"
        java -Xms${SERVER_MEMORY}M -Xmx${SERVER_MEMORY}M -jar bungeecord.jar &
    else
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
        animate_text "Server is starting... Enjoy!" "${GREEN}${BOLD}"
        echo -e "${MAGENTA}${BOLD}==========================================================================${NC}"
        java -Xms${SERVER_MEMORY}M -Xmx${SERVER_MEMORY}M $JAVA_FLAGS \
            -XX:+UseCompressedOops \
            -jar server.jar nogui &
    fi

    SERVER_PID=$!
}

# Function to stop the server
stop_server() {
    animate_text "Stopping server..." "${YELLOW}${BOLD}"
    if [ "$SERVER_TYPE" = "bedrock" ]; then
        kill $SERVER_PID
    else
        kill -SIGINT $SERVER_PID
    fi
    wait $SERVER_PID
    animate_text "Server stopped." "${RED}${BOLD}"
}

# Function to check for player connections
check_player_connection() {
    # This is a placeholder. You need to implement the actual check based on your server setup.
    # For example, you might check server logs or use a plugin to detect player connections.
    # Return 0 if a player is trying to connect, 1 otherwise.
    return 1
}

# Start the server initially
start_server

# Main loop
while true; do
    # Wait for 5 minutes
    sleep 300

    # Check if any players are connected
    if ! check_player_connection; then
        stop_server
        animate_text "Server is now in standby mode. It will start automatically when a player tries to join." "${CYAN}${BOLD}"
        
        # Wait for a player to try to connect
        while true; do
            if check_player_connection; then
                animate_text "Player attempting to connect. Starting server..." "${GREEN}${BOLD}"
                start_server
                break
            fi
            sleep 10
        done
    fi
done
