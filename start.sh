#!/bin/bash

# Advanced color and style definitions
declare -A colors=(
    [black]='\033[0;30m' [red]='\033[0;31m' [green]='\033[0;32m' [yellow]='\033[0;33m'
    [blue]='\033[0;34m' [purple]='\033[0;35m' [cyan]='\033[0;36m' [white]='\033[0;37m'
    [bold_black]='\033[1;30m' [bold_red]='\033[1;31m' [bold_green]='\033[1;32m'
    [bold_yellow]='\033[1;33m' [bold_blue]='\033[1;34m' [bold_purple]='\033[1;35m'
    [bold_cyan]='\033[1;36m' [bold_white]='\033[1;37m'
)
NC='\033[0m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
BLINK='\033[5m'
REVERSE='\033[7m'

# Advanced animation functions
animate_text() {
    local text="$1"
    local color="${colors[$2]}"
    local delay=${3:-0.03}
    printf "${color}"
    for ((i=0; i<${#text}; i++)); do
        printf "${text:$i:1}"
        sleep $delay
    done
    printf "${NC}\n"
}

rainbow_text() {
    local text="$1"
    local rainbow=(red yellow green cyan blue purple)
    for ((i=0; i<${#text}; i++)); do
        printf "${colors[${rainbow[i % 6]}]}${text:$i:1}"
        sleep 0.01
    done
    printf "${NC}\n"
}

matrix_rain() {
    local duration=$1
    local columns=$(tput cols)
    local rows=$(tput lines)
    trap "tput cnorm; exit" INT
    tput civis
    for ((i=0; i<duration*10; i++)); do
        for ((j=0; j<columns; j++)); do
            printf "\033[%d;%dH\033[32m%s" $((RANDOM%rows)) $j "${matrix_chars[RANDOM%${#matrix_chars[@]}]}"
        done
        sleep 0.1
    done
    tput cnorm
}

# Fancy progress bar with gradients
fancy_progress_bar() {
    local duration=$1
    local width=50
    local gradient=('🟥' '🟧' '🟨' '🟩' '🟦' '🟪')
    local delay=$(bc <<< "scale=3; $duration / $width")
    for ((i=0; i<=width; i++)); do
        local percentage=$((i*100/width))
        printf "\r["
        for ((j=0; j<i; j++)); do
            printf "${gradient[j % 6]}"
        done
        for ((j=i; j<width; j++)); do
            printf " "
        done
        printf "] %3d%%" $percentage
        sleep $delay
    done
    echo
}

# 3D rotating cube animation
rotate_cube() {
    local duration=$1
    local frames=(
        "    ┌───────┐    "
        "   ╱       ╱│   "
        "  ┌───────┐ │   "
        "  │       │ │   "
        "  │   •   │ │   "
        "  │       │╱    "
        "  └───────┘     "
        "                "
        "    ┌───────┐    "
        "   ╱       ╱│   "
        "  ┌───────┐ │   "
        "  │       │ │   "
        "  │       │ │   "
        "  │     • │╱    "
        "  └───────┘     "
        "                "
        "    ┌───────┐    "
        "   ╱       ╱│   "
        "  ┌───────┐ │   "
        "  │       │ │   "
        "  │       │ │   "
        "  │       │╱    "
        "  └───────┘     "
        "        •       "
    )
    local frame_count=${#frames[@]}
    local frame_height=8
    for ((i=0; i<duration*5; i++)); do
        local frame_index=$((i % frame_count))
        printf "\033[${frame_height}A"
        for ((j=0; j<frame_height; j++)); do
            echo -e "\033[K${frames[frame_index * frame_height + j]}"
        done
        sleep 0.2
    done
}

# Dynamic server status display
show_server_status() {
    local pid=$1
    while ps -p $pid > /dev/null; do
        clear
        cat << EOF
${colors[bold_cyan]}╔════════════════════════════════════════════════════════════════╗
║                     CZARACTYL SERVER STATUS                     ║
╚════════════════════════════════════════════════════════════════╝${NC}

${colors[bold_green]}Server PID:${NC} $pid
${colors[bold_yellow]}Uptime:${NC} $(ps -o etime= -p $pid)
${colors[bold_magenta]}Memory Usage:${NC} $(ps -o %mem= -p $pid)%
${colors[bold_blue]}CPU Usage:${NC} $(ps -o %cpu= -p $pid)%
${colors[bold_red]}Players Online:${NC} $(grep -c "logged in with entity id" logs/latest.log)

${colors[bold_cyan]}╔════════════════════════════════════════════════════════════════╗
║                   Press any key to return to menu                ║
╚════════════════════════════════════════════════════════════════╝${NC}
EOF
        read -t 1 -N 1 input
        if [ $? = 0 ]; then
            return
        fi
    done
}

# Interactive menu
show_menu() {
    while true; do
        clear
        cat << EOF
${colors[bold_cyan]}╔════════════════════════════════════════════════════════════════╗
║                      CZARACTYL CONTROL PANEL                     ║
╚════════════════════════════════════════════════════════════════╝${NC}

${colors[bold_green]}1)${NC} Start Server
${colors[bold_red]}2)${NC} Stop Server
${colors[bold_yellow]}3)${NC} Restart Server
${colors[bold_blue]}4)${NC} Create Backup
${colors[bold_magenta]}5)${NC} Show Server Status
${colors[bold_cyan]}6)${NC} View Logs
${colors[bold_white]}7)${NC} Exit

${colors[bold_cyan]}Enter your choice:${NC} 
EOF
        read -n 1 -s choice
        case $choice in
            1) start_server ;;
            2) stop_server ;;
            3) restart_server ;;
            4) create_backup ;;
            5) show_server_status $SERVER_PID ;;
            6) view_logs ;;
            7) exit_script ;;
            *) animate_text "Invalid option. Please try again." "bold_red" ;;
        esac
    done
}

# Enhanced server start function
start_server() {
    animate_text "Initializing Czaractyl Server..." "bold_green"
    rotate_cube 3 &
    cube_pid=$!

    # Server initialization logic here
    sleep 3
    kill $cube_pid
    wait $cube_pid 2>/dev/null

    SERVER_PID=$!
    animate_text "Server started successfully! PID: $SERVER_PID" "bold_green"
    fancy_progress_bar 3
}

# Enhanced server stop function
stop_server() {
    animate_text "Initiating server shutdown sequence..." "bold_red"
    matrix_rain 3 &
    rain_pid=$!

    # Server shutdown logic here
    sleep 3
    kill $rain_pid
    wait $rain_pid 2>/dev/null

    animate_text "Server has been gracefully shut down." "bold_red"
    fancy_progress_bar 2
}

# Restart server function
restart_server() {
    stop_server
    start_server
}

# Create backup function
create_backup() {
    backup_name="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    animate_text "Creating backup: $backup_name" "bold_yellow"
    
    # Backup creation logic here
    tar -czf "backups/$backup_name" world world_nether world_the_end
    
    fancy_progress_bar 3
    animate_text "Backup created successfully!" "bold_green"
}

# View logs function
view_logs() {
    animate_text "Loading server logs..." "bold_cyan"
    less +G logs/latest.log
}

# Exit script function
exit_script() {
    animate_text "Exiting Czaractyl Control Panel..." "bold_red"
    fancy_progress_bar 2
    exit 0
}

# Main script execution
clear
cat << "EOF"
${colors[bold_cyan]}
   ______                          __        __
  / ____/___ _____  ____ ______   / /___  __/ /
 / /   / __ `/_  / / __ `/ ___/  / __/ / / / / 
/ /___/ /_/ / / /_/ /_/ / /__   / /_/ /_/ / /  
\____/\__,_/ /___/\__,_/\___/   \__/\__,_/_/   
EOF

rainbow_text "Welcome to the Next Generation of Minecraft Server Management"
animate_text "Developed & Maintained By @arpitsinghog" "bold_magenta"
echo

# Initialize server
start_server

# Enter interactive menu
show_menu

# Main loop for server management
while true; do
    if ! ps -p $SERVER_PID > /dev/null 2>&1; then
        animate_text "Server has stopped unexpectedly. Restarting..." "bold_red"
        start_server
    fi

    # Check for player activity
    if ! grep -q "logged in with entity id" <(tail -n 50 logs/latest.log 2>/dev/null); then
        animate_text "No player activity detected. Server will hibernate in 5 minutes if no players join." "bold_yellow"
        sleep 300

        if ! grep -q "logged in with entity id" <(tail -n 50 logs/latest.log 2>/dev/null); then
            stop_server
            animate_text "Server is now in hibernation mode. It will start automatically when a player tries to join." "bold_cyan"
            
            while true; do
                if grep -q "logged in with entity id" <(tail -n 1 logs/latest.log 2>/dev/null); then
                    animate_text "Player attempting to connect. Starting server..." "bold_green"
                    start_server
                    break
                fi
                sleep 10
            done
        fi
    fi

    sleep 60
done
