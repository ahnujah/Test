#!/bin/bash

# ANSI color codes and styles
CYAN='\033[0;36m'
GREEN='\033[0;32m'
WHITE='\033[0;37m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'
BOLD='\033[1m'

# Global variables
SERVER_PID=""
SERVER_TYPE=""
SERVER_MEMORY=1024
HIBERNATE_TIMEOUT=300
HIBERNATE_ENABLED=true

# Function to clear screen and set cursor
clear_screen() {
    echo -e "\033c"
    tput civis
}

# Function to show cursor
show_cursor() {
    tput cnorm
}

# Function to display server stats
show_stats() {
    local cpu_usage=$(ps -p $SERVER_PID -o %cpu= 2>/dev/null || echo "0.00")
    local mem_usage=$(ps -p $SERVER_PID -o %mem= 2>/dev/null || echo "0.00")
    local uptime=$(ps -o etime= -p $SERVER_PID 2>/dev/null || echo "00:00")
    
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║ Server ID: ${WHITE}b1a2f8c1-8c80-4ccb-9d...${CYAN}                           ║${NC}"
    echo -e "${CYAN}║ CPU Load: ${WHITE}${cpu_usage}% ${CYAN}                                          ║${NC}"
    echo -e "${CYAN}║ Memory: ${WHITE}${mem_usage}MiB ${CYAN}                                         ║${NC}"
    echo -e "${CYAN}║ Uptime: ${WHITE}${uptime}${CYAN}                                            ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
}

# Function to display menu
show_menu() {
    clear_screen
    echo -e "${CYAN}\033[1;36m"
    cat << "EOF"
\033[1m\033[36m
 ██████╗███████╗ █████╗ ██████╗  █████╗  ██████╗████████╗██╗   ██╗██╗     
██╔════╝╚══███╔╝██╔══██╗██╔══██╗██╔══██╗██╔════╝╚══██╔══╝╚██╗ ██╔╝██║     
██║       ███╔╝ ███████║██████╔╝███████║██║        ██║    ╚████╔╝ ██║     
██║      ███╔╝  ██╔══██║██╔══██╗██╔══██║██║        ██║     ╚██╔╝  ██║     
╚██████╗███████╗██║  ██║██║  ██║██║  ██║╚██████╗   ██║      ██║   ███████╗
 ╚═════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝   ╚═╝      ╚═╝   ╚══════╝
EOF
    echo -e "${NC}"
    
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    CZARACTYL CONTROL PANEL                     ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "\033[1;32m1)\033[0m Start Server"
    echo -e "\033[1;31m2)\033[0m Stop Server"
    echo -e "\033[1;33m3)\033[0m Restart Server"
    echo -e "\033[1;34m4)\033[0m Create Backup"
    echo -e "\033[1;35m5)\033[0m Show Server Status"
    echo -e "\033[1;36m6)\033[0m View Logs"
    echo -e "\033[1;37m7)\033[0m Configure Server"
    echo -e "\033[1;32m8)\033[0m Toggle Hibernation"
    echo -e "\033[1;31m9)\033[0m Exit"
    echo
    echo -e "${CYAN}Enter your choice:\033[0m "
}

# Function to start server
start_server() {
    if ps -p $SERVER_PID > /dev/null 2>&1; then
        echo -e "${YELLOW}Server is already running.${NC}"
        return
    fi

    echo -e "${GREEN}Starting server...${NC}"
    
    if [ "$SERVER_TYPE" = "bedrock" ]; then
        LD_LIBRARY_PATH=. ./bedrock_server &
    elif [ "$SERVER_TYPE" = "bungeecord" ]; then
        java -Xms${SERVER_MEMORY}M -Xmx${SERVER_MEMORY}M -jar bungeecord.jar &
    else
        java -Xms${SERVER_MEMORY}M -Xmx${SERVER_MEMORY}M -XX:+UseG1GC -XX:+ParallelRefProcEnabled \
             -XX:MaxGCPauseMillis=200 -jar server.jar nogui &
    fi

    SERVER_PID=$!
    echo -e "${GREEN}Server started successfully! PID: $SERVER_PID${NC}"
    sleep 2
}

# Function to stop server
stop_server() {
    if ! ps -p $SERVER_PID > /dev/null 2>&1; then
        echo -e "${YELLOW}Server is not running.${NC}"
        return
    fi

    echo -e "${RED}Stopping server...${NC}"
    
    if [ "$SERVER_TYPE" = "bedrock" ]; then
        kill $SERVER_PID
    else
        screen -S minecraft -X stuff "stop$(printf '\r')"
    fi
    wait $SERVER_PID 2>/dev/null
    
    echo -e "${RED}Server stopped.${NC}"
    SERVER_PID=""
    sleep 2
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

# Function to display server starting message
display_server_starting_message() {
    clear_screen
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    SERVER STARTING IN 2 MINUTES                 ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    for i in {120..1}; do
        echo -ne "\r\033[KTime remaining: ${WHITE}%02d:%02d${NC}" $((i/60)) $((i%60))
        sleep 1
    done
    
    echo -e "\n\n${GREEN}Server is now ready! Enjoy your game!${NC}"
    sleep 2
}

# Main script execution
trap 'show_cursor; exit' INT TERM

# Initialize server
clear_screen
show_menu
start_server

# Main loop for server management
while true; do
    if ! ps -p $SERVER_PID > /dev/null 2>&1; then
        echo -e "${RED}Server has stopped unexpectedly. Restarting...${NC}"
        start_server
    fi

    if $HIBERNATE_ENABLED; then
        if ! check_player_connection; then
            echo -e "${YELLOW}No player activity detected. Server will hibernate in $((HIBERNATE_TIMEOUT/60)) minutes if no players join.${NC}"
            sleep $HIBERNATE_TIMEOUT

            if ! check_player_connection; then
                stop_server
                echo -e "${CYAN}Server is now in hibernation mode. It will start automatically when a player tries to join.${NC}"
                
                while true; do
                    if check_player_connection; then
                        display_server_starting_message
                        start_server
                        break
                    fi
                    sleep 10

                    # Check for user input during hibernation
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
                            5) show_stats ;;
                            6) less +G logs/latest.log ;;
                            7)
                                echo -e "${CYAN}Current settings:${NC}"
                                echo "Server Type: $SERVER_TYPE"
                                echo "Server Memory: ${SERVER_MEMORY}MB"
                                echo "Hibernate Timeout: ${HIBERNATE_TIMEOUT}s"
                                ;;
                            8)
                                HIBERNATE_ENABLED=!$HIBERNATE_ENABLED
                                echo -e "${CYAN}Hibernation: $([ $HIBERNATE_ENABLED = true ] && echo 'Enabled' || echo 'Disabled')${NC}"
                                ;;
                            9)
                                echo -e "${RED}Exiting...${NC}"
                                stop_server
                                show_cursor
                                exit 0
                                ;;
                        esac
                        show_menu
                        if ps -p $SERVER_PID > /dev/null 2>&1; then
                            break
                        fi
                    fi
                done
            fi
        fi
    fi

    # Update stats every minute
    show_stats
    sleep 60
done
