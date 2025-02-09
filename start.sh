#!/bin/bash

# ANSI color codes and styles
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
BLINK='\033[5m'
REVERSE='\033[7m'
NC='\033[0m'

# Function to display animated text with gradient
animate_gradient_text() {
    text="$1"
    start_color="$2"
    end_color="$3"
    delay=${4:-0.02}
    
    for (( i=0; i<${#text}; i++ )); do
        r=$(( $(printf "%d" 0x${start_color:0:2}) + ($(printf "%d" 0x${end_color:0:2}) - $(printf "%d" 0x${start_color:0:2})) * i / ${#text} ))
        g=$(( $(printf "%d" 0x${start_color:2:2}) + ($(printf "%d" 0x${end_color:2:2}) - $(printf "%d" 0x${start_color:2:2})) * i / ${#text} ))
        b=$(( $(printf "%d" 0x${start_color:4:2}) + ($(printf "%d" 0x${end_color:4:2}) - $(printf "%d" 0x${start_color:4:2})) * i / ${#text} ))
        printf "\033[38;2;%d;%d;%dm%s\033[0m" $r $g $b "${text:$i:1}"
        sleep $delay
    done
    echo
}

# Function to display a fancy progress bar
fancy_progress_bar() {
    local duration=$1
    local width=50
    local bar_char="▓"
    local empty_char="░"
    local start_color="ff0000"
    local end_color="00ff00"
    
    for ((i=0; i<=width; i++)); do
        local percentage=$((i*100/width))
        local r=$(( $(printf "%d" 0x${start_color:0:2}) + ($(printf "%d" 0x${end_color:0:2}) - $(printf "%d" 0x${start_color:0:2})) * i / width ))
        local g=$(( $(printf "%d" 0x${start_color:2:2}) + ($(printf "%d" 0x${end_color:2:2}) - $(printf "%d" 0x${start_color:2:2})) * i / width ))
        local b=$(( $(printf "%d" 0x${start_color:4:2}) + ($(printf "%d" 0x${end_color:4:2}) - $(printf "%d" 0x${start_color:4:2})) * i / width ))
        
        printf "\r\033[38;2;%d;%d;%dm[%-${width}s] %3d%%\033[0m" $r $g $b "$(printf "%0.s${bar_char}" $(seq 1 $i))$(printf "%0.s${empty_char}" $(seq 1 $((width-i))))" $percentage
        sleep $(bc <<< "scale=3; $duration / $width")
    done
    echo
}

# Clear screen and show banner
clear
echo -e "${CYAN}${BOLD}"
cat << "EOF"
   ▄████████  ▄███████▄     ▄████████    ▄████████    ▄████████  ▄████████     ███      ▄██   ▄   ▄█       
  ███    ███ ██▀     ▄██   ███    ███   ███    ███   ███    ███ ███    ███ ▀█████████▄ ███   ██▄ ███       
  ███    █▀        ▄███▀   ███    ███   ███    ███   ███    ███ ███    █▀     ▀███▀▀██ ███▄▄▄███ ███       
  ███         ▀█▀▄███▀▄▄   ███    ███  ▄███▄▄▄▄██▀   ███    ███ ███            ███   ▀ ▀▀▀▀▀▀███ ███       
▀███████████ ▄███▀   ▀▀ ▀█████████▀  ▀▀███▀▀▀▀▀   ▀███████████ ███            ███     ▄██   ███ ███       
         ███ ████▄     ▄   ███        ▀███████████   ███    ███ ███    █▄      ███     ███   ███ ███       
   ▄█    ███ ██▀    ▄██▀   ███          ███    ███   ███    ███ ███    ███     ███     ███   ███ ███▌    ▄ 
 ▄████████▀  ██████████   ▄████▀        ███    ███   ███    █▀  ████████▀     ▄████▀    ▀█████▀  █████▄▄██ 
                                        ███    ███                                                ▀         
EOF
echo -e "${NC}"

# Animated subtitle with gradient
animate_gradient_text "Welcome to the Next Generation of Minecraft Server Management" "ff0000" "00ffff"

# Colorful separator
echo -e "\n${MAGENTA}${BOLD}$(printf '█%.0s' {1..80})${NC}\n"

# Developer credit with animation and style
animate_gradient_text "Developed & Maintained By ${UNDERLINE}@arpitsinghog${NC}" "00ff00" "ff00ff" 0.03

# Another colorful separator
echo -e "\n${BLUE}${BOLD}$(printf '█%.0s' {1..80})${NC}\n"

# Function to start the server
start_server() {
    animate_gradient_text "Initializing Czaractyl Server..." "0000ff" "00ffff"
    fancy_progress_bar 3

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
        animate_gradient_text "No valid server files found. Running installation script..." "ffff00" "ff00ff"
        bash install.sh
        if [ ! -f "bedrock_server" ]; then
            animate_gradient_text "Installation failed! Could not find server files" "ff0000" "ff00ff"
            exit 1
        fi
    elif [ "$SERVER_TYPE" != "bedrock" ] && [ ! -f "server.jar" ]; then
        animate_gradient_text "No valid server.jar found. Running installation script..." "ffff00" "ff00ff"
        bash install.sh
        if [ ! -f "server.jar" ]; then
            animate_gradient_text "Installation failed! Could not find server.jar" "ff0000" "ff00ff"
            exit 1
        fi
    fi

    # Set default memory if not specified or if it's 0
    if [ -z "$SERVER_MEMORY" ] || [ "$SERVER_MEMORY" -eq 0 ]; then
        SERVER_MEMORY=1024
        animate_gradient_text "SERVER_MEMORY was not set or was 0. Using default value of 1024MB." "ffff00" "00ffff"
    fi

    # Create automatic backup directory
    mkdir -p backups

    # Perform automatic backup
    if [ "$SERVER_TYPE" != "bedrock" ] && [ "$SERVER_TYPE" != "bungeecord" ]; then
        backup_name="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
        animate_gradient_text "Creating automatic backup..." "00ffff" "0000ff"
        tar -czf "backups/$backup_name" world world_nether world_the_end
        fancy_progress_bar 2
        animate_gradient_text "Backup completed: $backup_name" "00ff00" "00ffff"
    fi

    animate_gradient_text "Starting server with ${SERVER_MEMORY}MB of RAM..." "00ff00" "ffff00"
    fancy_progress_bar 2

    if [ "$SERVER_TYPE" = "bedrock" ]; then
        animate_gradient_text "Launching Bedrock server..." "00ff00" "00ffff"
        LD_LIBRARY_PATH=. ./bedrock_server | tee >(sed 's/.*/./' > /dev/null) &
    elif [ "$SERVER_TYPE" = "bungeecord" ]; then
        animate_gradient_text "Launching BungeeCord server..." "00ff00" "00ffff"
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
        animate_gradient_text "Launching Java server... Prepare for adventure!" "00ff00" "ffff00"
        echo -e "${MAGENTA}${BOLD}$(printf '█%.0s' {1..80})${NC}"
        java -Xms${SERVER_MEMORY}M -Xmx${SERVER_MEMORY}M $JAVA_FLAGS \
            -XX:+UseCompressedOops \
            -jar server.jar nogui | tee >(sed 's/.*/./' > /dev/null) &
    fi

    SERVER_PID=$!
    animate_gradient_text "Server started successfully! PID: $SERVER_PID" "00ff00" "00ffff"
}

# Function to stop the server
stop_server() {
    animate_gradient_text "Initiating server shutdown sequence..." "ffff00" "ff0000"
    if [ "$SERVER_TYPE" = "bedrock" ]; then
        kill $SERVER_PID
    else
        screen -S minecraft -X stuff "stop$(printf '\r')"
    fi
    wait $SERVER_PID 2>/dev/null
    animate_gradient_text "Server has been gracefully shut down." "ff0000" "ffff00"
    fancy_progress_bar 2
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
    echo -e "${YELLOW}${BOLD}"
    read -p "Enter a command (start|stop|restart|backup|exit): " user_input
    echo -e "${NC}"
    case $user_input in
        exit)
            animate_gradient_text "Initiating Czaractyl shutdown sequence..." "ff0000" "ffff00"
            stop_server
            exit 0
            ;;
        start)
            if ! ps -p $SERVER_PID > /dev/null 2>&1; then
                start_server
            else
                animate_gradient_text "Server is already operational." "ffff00" "00ffff"
            fi
            ;;
        stop)
            if ps -p $SERVER_PID > /dev/null 2>&1; then
                stop_server
            else
                animate_gradient_text "Server is not currently running." "ffff00" "00ffff"
            fi
            ;;
        restart)
            animate_gradient_text "Initiating server restart sequence..." "ffff00" "00ffff"
            if ps -p $SERVER_PID > /dev/null 2>&1; then
                stop_server
            fi
            start_server
            ;;
        backup)
            backup_name="manual_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
            animate_gradient_text "Creating manual backup..." "00ffff" "0000ff"
            tar -czf "backups/$backup_name" world world_nether world_the_end
            fancy_progress_bar 2
            animate_gradient_text "Backup created successfully: $backup_name" "00ff00" "00ffff"
            ;;
        *)
            if ps -p $SERVER_PID > /dev/null 2>&1; then
                screen -S minecraft -X stuff "$user_input$(printf '\r')"
                animate_gradient_text "Command sent to server." "00ffff" "0000ff"
            else
                animate_gradient_text "Server is not running. Start it first." "ffff00" "ff0000"
            fi
            ;;
    esac
}

# Function to display server starting message
display_server_starting_message() {
    clear
    echo -e "${CYAN}${BOLD}"
    cat << "EOF"
   ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄        ▄  ▄▄▄▄▄▄▄▄▄▄▄ 
  ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░▌      ▐░▌▐░░░░░░░░░░░▌
  ▐░█▀▀▀▀▀▀▀▀▀  ▀▀▀▀█░█▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌ ▀▀▀▀█░█▀▀▀▀ ▐░█▀▀▀▀▀▀▀▀▀ ▐░▌░▌     ▐░▌▐░█▀▀▀▀▀▀▀▀▀ 
  ▐░▌               ▐░▌     ▐░▌       ▐░▌▐░▌       ▐░▌     ▐░▌     ▐░▌          ▐░▌▐░▌    ▐░▌▐░▌          
  ▐░█▄▄▄▄▄▄▄▄▄      ▐░▌     ▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌     ▐░▌     ▐░▌          ▐░▌ ▐░▌   ▐░▌▐░▌ ▄▄▄▄▄▄▄▄ 
  ▐░░░░░░░░░░░▌     ▐░▌     ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌     ▐░▌     ▐░▌          ▐░▌  ▐░▌  ▐░▌▐░▌▐░░░░░░░░▌
   ▀▀▀▀▀▀▀▀▀█░▌     ▐░▌     ▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀█░█▀▀      ▐░▌     ▐░▌          ▐░▌   ▐░▌ ▐░▌▐░▌ ▀▀▀▀▀▀█░▌
            ▐░▌     ▐░▌     ▐░▌       ▐░▌▐░▌     ▐░▌       ▐░▌     ▐░▌          ▐░▌    ▐░▌▐░▌▐░▌       ▐░▌
   ▄▄▄▄▄▄▄▄▄█░▌     ▐░▌     ▐░▌       ▐░▌▐░▌      ▐░▌      ▐░▌     ▐░█▄▄▄▄▄▄▄▄▄ ▐░▌     ▐░▐░▌▐░█▄▄▄▄▄▄▄█░▌
  ▐░░░░░░░░░░░▌     ▐░▌     ▐░▌       ▐░▌▐░▌       ▐░▌     ▐░▌     ▐░░░░░░░░░░░▌▐░▌      ▐░░▌▐░░░░░░░░░░░▌
   ▀▀▀▀▀▀▀▀▀▀▀       ▀       ▀         ▀  ▀         ▀       ▀       ▀▀▀▀▀▀▀▀▀▀▀  ▀        ▀▀  ▀▀▀▀▀▀▀▀▀▀▀ 
EOF
    echo -e "${NC}"

    animate_gradient_text "Server is starting... Please wait 2 minutes" "00ffff" "ff00ff"
    echo -e "\n${MAGENTA}${BOLD}$(printf '█%.0s' {1..80})${NC}\n"
    animate_gradient_text "Preparing your Minecraft adventure..." "00ff00" "ffff00"
    
    for i in {120..1}; do
        printf "\r\033[KTime remaining: %02d:%02d" $((i/60)) $((i%60))
        sleep 1
    done
    
    echo -e "\n\n${GREEN}${BOLD}Server is now ready! Enjoy your game!${NC}\n"
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
        animate_gradient_text "Server has stopped unexpectedly. Restarting..." "ff0000" "ffff00"
        start_server
    fi

    # Check for player activity every 5 minutes
    if ! check_player_connection; then
        animate_gradient_text "No player activity detected. Server will hibernate in 5 minutes if no players join." "ffff00" "00ffff"
        sleep 300

        if ! check_player_connection; then
            stop_server
            animate_gradient_text "Server is now in hibernation mode. It will start automatically when a player tries to join." "00ffff" "0000ff"
            
            # Wait for a player to try to connect
            while true; do
                if check_player_connection; then
                    display_server_starting_message
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
