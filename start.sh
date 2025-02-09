#!/bin/bash
# start.sh

# ANSI color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BLUE='\033[0;34m'
WHITE='\033[1;37m'
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

# Animated subtitle
animate_text "Welcome to the Next Generation of Minecraft Server Management" "${YELLOW}${BOLD}"

# Colorful separator
echo -e "${MAGENTA}${BOLD}==========================================================================${NC}"

# Developer credit with animation
animate_text "Developed & Maintained By @arpit_singh_boy" "${CYAN}${BOLD}"

# Another colorful separator
echo -e "${BLUE}${BOLD}==========================================================================${NC}"

animate_text "Czaractyl Server Startup Sequence Initiated" "${GREEN}${BOLD}"

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
        LD_LIBRARY_PATH=. ./bedrock_server | tee >(sed 's/.*/./' > /dev/null) &
    elif [ "$SERVER_TYPE" = "bungeecord" ]; then
        animate_text "Starting BungeeCord server..." "${GREEN}${BOLD}"
        java -Xms${SERVER_MEMORY}M -Xmx${SERVER_MEMORY}M -jar bungeecord.jar | tee >(sed 's/.*/./' > /dev/null) &
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
            -jar server.jar nogui | tee >(sed 's/.*/./' > /dev/null) &
    fi

    SERVER_PID=$!
}

# Function to stop the server
stop_server() {
    animate_text "Stopping server..." "${YELLOW}${BOLD}"
    if [ "$SERVER_TYPE" = "bedrock" ]; then
        kill $SERVER_PID
    else
        screen -S minecraft -X stuff "stop$(printf '\r')"
    fi
    wait $SERVER_PID 2>/dev/null
    animate_text "Server stopped." "${RED}${BOLD}"
}

# Function to check for player connections
check_player_connection() {
    if [ "$SERVER_TYPE" = "bedrock" ]; then
        if grep -q "Player connected" <(tail -n 50 logs/latest.log 2>/dev/null); then
            return 0
        fi
    else
        if grep -q "logged in with entity id" <(tail -n 50 logs/latest.log 2>/dev/null); then
            return 0
        fi
    fi
    return 1
}

# Function to handle user input
handle_user_input() {
    read -p "Enter a command (or 'exit' to quit): " user_input
    case $user_input in
        exit)
            stop_server
            exit 0
            ;;
        start)
            if ! ps -p $SERVER_PID > /dev/null 2>&1; then
                start_server
            else
                animate_text "Server is already running." "${YELLOW}${BOLD}"
            fi
            ;;
        stop)
            if ps -p $SERVER_PID > /dev/null 2>&1; then
                stop_server
            else
                animate_text "Server is not running." "${YELLOW}${BOLD}"
            fi
            ;;
        restart)
            if ps -p $SERVER_PID > /dev/null 2>&1; then
                stop_server
            fi
            start_server
            ;;
        backup)
            backup_name="manual_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
            animate_text "Creating manual backup..." "${CYAN}"
            tar -czf "backups/$backup_name" world world_nether world_the_end
            animate_text "Backup created: $backup_name" "${GREEN}${BOLD}"
            ;;
        *)
            if ps -p $SERVER_PID > /dev/null 2>&1; then
                screen -S minecraft -X stuff "$user_input$(printf '\r')"
            else
                animate_text "Server is not running. Start it first." "${YELLOW}${BOLD}"
            fi
            ;;
    esac
}

# Start the server initially
start_server

# Main loop
while true; do
    # Check for user input (non-blocking)
    if read -t 0.1 -N 1 input; then
        handle_user_input
    fi

    # Check if server is running
    if ! ps -p $SERVER_PID > /dev/null 2>&1; then
        animate_text "Server has stopped unexpectedly. Restarting..." "${RED}${BOLD}"
        start_server
    fi

    # Check for player activity every 5 minutes
    if ! check_player_connection; then
        animate_text "No player activity detected. Server will hibernate in 5 minutes if no players join." "${YELLOW}${BOLD}"
        sleep 300

        if ! check_player_connection; then
            stop_server
            animate_text "Server is now in hibernation mode. It will start automatically when a player tries to join." "${CYAN}${BOLD}"
            
            # Wait for a player to try to connect
            while true; do
                if check_player_connection; then
                    animate_text "Player attempting to connect. Starting server..." "${GREEN}${BOLD}"
                    start_server
                    break
                fi
                sleep 10

                # Check for user input during hibernation
                if read -t 0.1 -N 1 input; then
                    handle_user_input
                    if ps -p $SERVER_PID > /dev/null 2>&1; then
                        break
                    fi
                fi
            done
        fi
    fi

    sleep 1
done
