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

# Global variables
SERVER_PID=""
SERVER_TYPE=""
SERVER_MEMORY=1024
HIBERNATE_TIMEOUT=300

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
    local matrix_chars=(ｱ ｲ ｳ ｴ ｵ ｶ ｷ ｸ ｹ ｺ ｻ ｼ ｽ ｾ ｿ ﾀ ﾁ ﾂ ﾃ ﾄ ﾅ ﾆ ﾇ ﾈ ﾉ ﾊ ﾋ ﾌ ﾍ ﾎ ﾏ ﾐ ﾑ ﾒ ﾓ ﾔ ﾕ ﾖ ﾗ ﾘ ﾙ ﾚ ﾛ ﾜ ﾝ)
    trap "tput cnorm; return" INT
    tput civis
    for ((i=0; i<duration*10; i++)); do
        for ((j=0; j<columns; j++)); do
            printf "\033[%d;%dH\033[32m%s" $((RANDOM%rows)) $j "${matrix_chars[RANDOM%${#matrix_chars[@]}]}"
        done
        sleep 0.1
    done
    tput cnorm
}

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

show_server_status() {
    while ps -p $SERVER_PID > /dev/null 2>&1; do
        clear
        cat << EOF
${colors[bold_cyan]}╔════════════════════════════════════════════════════════════════╗
║                     CZARACTYL SERVER STATUS                     ║
╚════════════════════════════════════════════════════════════════╝${NC}

${colors[bold_green]}Server PID:${NC} $SERVER_PID
${colors[bold_yellow]}Uptime:${NC} $(ps -o etime= -p $SERVER_PID)
${colors[bold_magenta]}Memory Usage:${NC} $(ps -o %mem= -p $SERVER_PID)%
${colors[bold_blue]}CPU Usage:${NC} $(ps -o %cpu= -p $SERVER_PID)%
${colors[bold_red]}Players Online:${NC} $(grep -c "logged in with entity id" logs/latest.log 2>/dev/null || echo "N/A")

${colors[bold_cyan]}╔════════════════════════════════════════════════════════════════╗
║                   Press any key to return to menu                ║
╚════════════════════════════════════════════════════════════════╝${NC}
EOF
        read -t 1 -N 1 input
        if [ $? = 0 ]; then
            return
        fi
    done
    animate_text "Server is not running." "bold_red"
    read -n 1 -s -r -p "Press any key to continue..."
}

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
${colors[bold_white]}7)${NC} Configure Server
${colors[bold_green]}8)${NC} Toggle Hibernation
${colors[bold_red]}9)${NC} Exit

${colors[bold_cyan]}Enter your choice:${NC} 
EOF
        read -n 1 -s choice
        case $choice in
            1) start_server ;;
            2) stop_server ;;
            3) restart_server ;;
            4) create_backup ;;
            5) show_server_status ;;
            6) view_logs ;;
            7) configure_server ;;
            8) toggle_hibernation ;;
            9) exit_script ;;
            *) animate_text "Invalid option. Please try again." "bold_red" ;;
        esac
    done
}

start_server() {
    if ps -p $SERVER_PID > /dev/null 2>&1; then
        animate_text "Server is already running." "bold_yellow"
        return
    fi

    animate_text "Initializing Czaractyl Server..." "bold_green"
    rotate_cube 3 &
    cube_pid=$!

    if [ "$SERVER_TYPE" = "bedrock" ]; then
        LD_LIBRARY_PATH=. ./bedrock_server &
    elif [ "$SERVER_TYPE" = "bungeecord" ]; then
        java -Xms${SERVER_MEMORY}M -Xmx${SERVER_MEMORY}M -jar bungeecord.jar &
    else
        java -Xms${SERVER_MEMORY}M -Xmx${SERVER_MEMORY}M -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -jar server.jar nogui &
    fi

    SERVER_PID=$!
    kill $cube_pid
    wait $cube_pid 2>/dev/null

    animate_text "Server started successfully! PID: $SERVER_PID" "bold_green"
    fancy_progress_bar 3
}

stop_server() {
    if ! ps -p $SERVER_PID > /dev/null 2>&1; then
        animate_text "Server is not running." "bold_yellow"
        return
    fi

    animate_text "Initiating server shutdown sequence..." "bold_red"
    matrix_rain 3 &
    rain_pid=$!

    if [ "$SERVER_TYPE" = "bedrock" ]; then
        kill $SERVER_PID
    else
        screen -S minecraft -X stuff "stop$(printf '\r')"
    fi
    wait $SERVER_PID 2>/dev/null

    kill $rain_pid
    wait $rain_pid 2>/dev/null

    animate_text "Server has been gracefully shut down." "bold_red"
    fancy_progress_bar 2
    SERVER_PID=""
}

restart_server() {
    stop_server
    start_server
}

create_backup() {
    backup_name="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    animate_text "Creating backup: $backup_name" "bold_yellow"
    
    mkdir -p backups
    tar -czf "backups/$backup_name" world world_nether world_the_end
    
    fancy_progress_bar 3
    animate_text "Backup created successfully!" "bold_green"
}

view_logs() {
    animate_text "Loading server logs..." "bold_cyan"
    less +G logs/latest.log
}

configure_server() {
    while true; do
        clear
        cat << EOF
${colors[bold_cyan]}╔════════════════════════════════════════════════════════════════╗
║                     SERVER CONFIGURATION                         ║
╚════════════════════════════════════════════════════════════════╝${NC}

${colors[bold_green]}1)${NC} Set Server Type (Current: $SERVER_TYPE)
${colors[bold_yellow]}2)${NC} Set Server Memory (Current: ${SERVER_MEMORY}MB)
${colors[bold_blue]}3)${NC} Set Hibernate Timeout (Current: ${HIBERNATE_TIMEOUT}s)
${colors[bold_red]}4)${NC} Back to Main Menu

${colors[bold_cyan]}Enter your choice:${NC} 
EOF
        read -n 1 -s subchoice
        case $subchoice in
            1)
                echo
                read -p "Enter server type (java/bedrock/bungeecord): " new_type
                if [[ "$new_type" =~ ^(java|bedrock|bungeecord)$ ]]; then
                    SERVER_TYPE=$new_type
                    animate_text "Server type updated to $SERVER_TYPE" "bold_green"
                else
                    animate_text "Invalid server type. Please try again." "bold_red"
                fi
                ;;
            2)
                echo
                read -p "Enter server memory in MB: " new_memory
                if [[ "$new_memory" =~ ^[0-9]+$ ]]; then
                    SERVER_MEMORY=$new_memory
                    animate_text "Server memory updated to ${SERVER_MEMORY}MB" "bold_green"
                else
                    animate_text "Invalid memory value. Please enter a number." "bold_red"
                fi
                ;;
            3)
                echo
                read -p "Enter hibernate timeout in seconds: " new_timeout
                if [[ "$new_timeout" =~ ^[0-9]+$ ]]; then
                    HIBERNATE_TIMEOUT=$new_timeout
                    animate_text "Hibernate timeout updated to ${HIBERNATE_TIMEOUT}s" "bold_green"
                else
                    animate_text "Invalid timeout value. Please enter a number." "bold_red"
                fi
                ;;
            4) return ;;
            *) animate_text "Invalid option. Please try again." "bold_red" ;;
        esac
        read -n 1 -s -r -p "Press any key to continue..."
    done
}

toggle_hibernation() {
    if [ "$HIBERNATE_ENABLED" = true ]; then
        HIBERNATE_ENABLED=false
        animate_text "Hibernation disabled." "bold_red"
    else
        HIBERNATE_ENABLED=true
        animate_text "Hibernation enabled." "bold_green"
    fi
}

exit_script() {
    animate_text "Exiting Czaractyl Control Panel..." "bold_red"
    fancy_progress_bar 2
    exit 0
}

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

display_server_starting_message() {
    clear
    cat << EOF
${colors[bold_cyan]}
   ▄████████    ▄███████▄    ▄████████    ▄████████    ▄████████  ▄████████     ███      ▄██   ▄   ▄█       
  ███    ███   ███    ███   ███    ███   ███    ███   ███    ███ ███    ███ ▀█████████▄ ███   ██▄ ███       
  ███    █▀    ███    ███   ███    ███   ███    ███   ███    ███ ███    █▀     ▀███▀▀██ ███▄▄▄███ ███       
  ███          ███    ███   ███    ███  ▄███▄▄▄▄██▀   ███    ███ ███            ███   ▀ ▀▀▀▀▀▀███ ███       
▀███████████ ▀█████████▀  ▀███████████ ▀▀███▀▀▀▀▀   ▀███████████ ███            ███     ▄██   ███ ███       
         ███   ███          ███    ███ ▀███████████   ███    ███ ███    █▄      ███     ███   ███ ███       
   ▄█    ███   ███          ███    ███   ███    ███   ███    ███ ███    ███     ███     ███   ███ ███▌    ▄ 
 ▄████████▀   ▄████▀        ███    █▀    ███    ███   ███    █▀  ████████▀     ▄████▀    ▀█████▀  █████▄▄██ 
                                         ███    ███                                                ▀         
EOF

    rainbow_text "Server is starting... Please wait 2 minutes"
    echo -e "\n${colors[bold_magenta]}$(printf '═%.0s' {1..80})${NC}\n"
    animate_text "Preparing your Minecraft adventure..." "bold_yellow"
    
    for i in {120..1}; do
        printf "\r\033[KTime remaining: %02d:%02d" $((i/60)) $((i%60))
        sleep 1
    done
    
    echo -e "\n\n${colors[bold_green]}Server is now ready! Enjoy your game!${NC}\n"
}

# Main script execution
clear
cat << EOF
${colors[bold_cyan]}
   ▄████████    ▄███████▄    ▄████████    ▄████████    ▄████████  ▄████████     ███      ▄██   ▄   ▄█       
  ███    ███   ███    ███   ███    ███   ███    ███   ███    ███ ███    ███ ▀█████████▄ ███   ██▄ ███       
  ███    █▀    ███    ███   ███    ███   ███    ███   ███    ███ ███    █▀     ▀███▀▀██ ███▄▄▄███ ███       
  ███          ███    ███   ███    ███  ▄███▄▄▄▄██▀   ███    ███ ███            ███   ▀ ▀▀▀▀▀▀███ ███       
▀███████████ ▀█████████▀  ▀███████████ ▀▀███▀▀▀▀▀   ▀███████████ ███            ███     ▄██   ███ ███       
         ███   ███          ███    ███ ▀███████████   ███    ███ ███    █▄      ███     ███   ███ ███       
   ▄█    ███   ███          ███    ███   ███    ███   ███    ███ ███    ███     ███     ███   ███ ███▌    ▄ 
 ▄████████▀   ▄████▀        ███    █▀    ███    ███   ███    █▀  ████████▀     ▄████▀    ▀█████▀  █████▄▄██ 
                                         ███    ███                                                ▀         
EOF

rainbow_text "Welcome to the Next Generation of Minecraft Server Management"
animate_text "Developed & Maintained By @arpitsinghog" "bold_magenta"
echo

# Initialize server
start_server

# Enter interactive menu
show_menu

# Main loop for server management
HIBERNATE_ENABLED=true
while true; do
    if ! ps -p $SERVER_PID > /dev/null 2>&1; then
        animate_text "Server has stopped unexpectedly. Restarting..." "bold_red"
        start_server
    fi

    if $HIBERNATE_ENABLED; then
        if ! check_player_connection; then
            animate_text "No player activity detected. Server will hibernate in $((HIBERNATE_TIMEOUT/60)) minutes if no players join." "bold_yellow"
            sleep $HIBERNATE_TIMEOUT

            if ! check_player_connection; then
                stop_server
                animate_text "Server is now in hibernation mode. It will start automatically when a player tries to join." "bold_cyan"
                
                while true; do
                    if check_player_connection; then
                        display_server_starting_message
                        start_server
                        break
                    fi
                    sleep 10

                    # Check for user input during hibernation
                    if read -t 0.1 -N 1 input; then
                        show_menu
                        if ps -p $SERVER_PID > /dev/null 2>&1; then
                            break
                        fi
                    fi
                done
            fi
        fi
    fi

    sleep 60
done
