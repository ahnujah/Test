#!/bin/bash

# ANSI color codes
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
WHITE='\033[0;37m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Global variables
SERVER_PID=""
SERVER_TYPE=""
SERVER_MEMORY=1024
HIBERNATE_TIMEOUT=300

# Clear screen and show banner
clear_screen() {
    echo -e "\033c"
    cat << "EOF"
 ▄████▄▒███████▒▄▄▄       ██▀███   ▄▄▄       ▄████▄  ▄▄▄█████▓▓██   ██▓ ██▓    
▒██▀ ▀█ ▒ ▒ ▒ ▄▀░▒████▄    ▓██ ▒ ██▒▒████▄    ▒██▀ ▀█  ▓  ██▒ ▓▒ ▒██  ██▒▓██▒    
▒▓█    ▄░ ▒ ▄▀▒░ ▒██  ▀█▄  ▓██ ░▄█ ▒▒██  ▀█▄  ▒▓█    ▄ ▒ ▓██░ ▒░  ▒██ ██░▒██░    
▒▓▓▄ ▄██▒██▄▄▄▄██░██▄▄▄▄██ ▒██▀▀█▄  ░██▄▄▄▄██▒▓▓▄ ▄██░░ ▓██▓ ░   ░ ▐██▓░▒██░    
▒ ▓███▀ ░▓█   ▓██▒▓█   ▓██▒░██▓ ▒██▒ ▓█   ▓██▒ ▓███▀ ░  ▒██▒ ░   ░ ██▒▓░░██████▒
░ ░▒ ▒  ░▒▒   ▓▒█░▒▒   ▓▒█░░ ▒▓ ░▒▓░ ▒▒   ▓▒█░ ░▒ ▒  ░  ▒ ░░      ██▒▒▒ ░ ▒░▓  ░
  ░  ▒    ▒   ▒▒ ░ ▒   ▒▒ ░  ░▒ ░ ▒░  ▒   ▒▒ ░ ░  ▒       ░     ▓██ ░▒░ ░ ░ ▒  ░
░         ░   ▒    ░   ▒     ░░   ░   ░   ▒  ░          ░       ▒ ▒ ░░    ░ ░   
░ ░           ░  ░     ░  ░   ░           ░  ░░ ░                ░ ░         ░  ░
░                                             ░                   ░ ░             
EOF
    echo
    echo -e "${CYAN}┌──────────────────── CZARACTYL CONTROL PANEL ────────────────────┐${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────────────────────┘${NC}"
    echo
}

# Show menu options
show_menu() {
    echo "1) Start Server"
    echo "2) Stop Server"
    echo "3) Restart Server"
    echo "4) Create Backup"
    echo "5) Show Server Status"
    echo "6) View Logs"
    echo "7) Configure Server"
    echo "8) Toggle Hibernation"
    echo "9) Exit"
    echo
    echo -e "Enter your choice: "
}

# Start server function
start_server() {
    echo -e "${GREEN}Starting server...${NC}"
    
    if [ "$SERVER_TYPE" = "bedrock" ]; then
        LD_LIBRARY_PATH=. ./bedrock_server &
    else
        java -Xms${SERVER_MEMORY}M -Xmx${SERVER_MEMORY}M -jar server.jar nogui &
    fi

    SERVER_PID=$!
    echo -e "${GREEN}Server started successfully! PID: $SERVER_PID${NC}"
}

# Stop server function
stop_server() {
    if [ "$SERVER_TYPE" = "bedrock" ]; then
        kill $SERVER_PID
    else
        screen -S minecraft -X stuff "stop$(printf '\r')"
    fi
    wait $SERVER_PID 2>/dev/null
    echo -e "${RED}Server stopped.${NC}"
    SERVER_PID=""
}

# Check for player connections
check_player_connection() {
    if [ "$SERVER_TYPE" = "bedrock" ]; then
        grep -q "Player connected" <(tail -n 50 logs/latest.log 2>/dev/null)
    else
        grep -q "logged in with entity id" <(tail -n 50 logs/latest.log 2>/dev/null)
    fi
}

# Display server starting message
display_starting_message() {
    clear_screen
    echo -e "${CYAN}Server is starting... Please wait 2 minutes${NC}"
    echo
    
    for i in {120..1}; do
        echo -ne "\rTime remaining: ${WHITE}%02d:%02d${NC}" $((i/60)) $((i%60))
        sleep 1
    done
    echo -e "\n\n${GREEN}Server is now ready!${NC}"
}

# Main script execution
clear_screen
show_menu

# Main loop
while true; do
    if ! ps -p $SERVER_PID > /dev/null 2>&1; then
        echo -e "${RED}Server has stopped unexpectedly. Restarting...${NC}"
        start_server
    fi

    if ! check_player_connection; then
        echo -e "${YELLOW}No player activity detected. Server will hibernate in 5 minutes if no players join.${NC}"
        sleep 300

        if ! check_player_connection; then
            stop_server
            echo -e "${CYAN}Server is now in hibernation mode. It will start automatically when a player tries to join.${NC}"
            
            while true; do
                if check_player_connection; then
                    display_starting_message
                    start_server
                    break
                fi
                sleep 10

                if read -t 0.1 -N 1 input; then
                    case $input in
                        1) start_server ;;
                        2) stop_server ;;
                        3) 
                            stop_server
                            start_server
                            ;;
                        4)
                            echo -e "${CYAN}Creating backup...${NC}"
                            backup_name="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
                            mkdir -p backups
                            tar -czf "backups/$backup_name" world world_nether world_the_end
                            echo -e "${GREEN}Backup created: $backup_name${NC}"
                            ;;
                        9)
                            echo -e "${RED}Exiting...${NC}"
                            stop_server
                            exit 0
                            ;;
                    esac
                    clear_screen
                    show_menu
                    if ps -p $SERVER_PID > /dev/null 2>&1; then
                        break
                    fi
                fi
            done
        fi
    fi

    # Show basic stats
    echo -e "\n${CYAN}Server ID: ${WHITE}b1a2f8c1-8c80-4ccb-9d...${NC}"
    echo -e "${CYAN}CPU Load: ${WHITE}$(ps -p $SERVER_PID -o %cpu= 2>/dev/null || echo "0.00")%${NC}"
    echo -e "${CYAN}Memory: ${WHITE}$(ps -p $SERVER_PID -o %mem= 2>/dev/null || echo "0.00")MiB${NC}"
    
    sleep 60
done
