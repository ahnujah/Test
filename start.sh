#!/bin/bash

# ANSI color codes and styles
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

# Global variables
SERVER_PID=""
SERVER_TYPE=""
SERVER_MEMORY=1024
SELECTED_SOFTWARE=""

# Function to display animated text
animate_text() {
    text="$1"
    color="${colors[$2]}"
    delay=${3:-0.03}
    printf "${color}"
    for ((i=0; i<${#text}; i++)); do
        printf "${text:$i:1}"
        sleep $delay
    done
    printf "${NC}\n"
}

# Function to display a fancy progress bar
fancy_progress_bar() {
    local duration=$1
    local width=50
    local bar_char="▓"
    local empty_char="░"
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

# Clear screen and show banner
clear_screen() {
    echo -e "\033c"
    cat << "EOF"
 ██████╗███████╗ █████╗ ██████╗  █████╗  ██████╗████████╗██╗   ██╗██╗     
██╔════╝╚══███╔╝██╔══██╗██╔══██╗██╔══██╗██╔════╝╚══██╔══╝╚██╗ ██╔╝██║     
██║       ███╔╝ ███████║██████╔╝███████║██║        ██║    ╚████╔╝ ██║     
██║      ███╔╝  ██╔══██║██╔══██╗██╔══██║██║        ██║     ╚██╔╝  ██║     
╚██████╗███████╗██║  ██║██║  ██║██║  ██║╚██████╗   ██║      ██║   ███████╗
 ╚═════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝   ╚═╝      ╚═╝   ╚══════╝
EOF
    echo
    animate_text "Welcome to the Next Generation of Minecraft Server Management" "bold_cyan" 0.02
    echo
    echo -e "${colors[bold_cyan]}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${colors[bold_cyan]}║                    CZARACTYL CONTROL PANEL                    ║${NC}"
    echo -e "${colors[bold_cyan]}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo
}

# Show software selection menu
select_software() {
    echo -e "${colors[bold_cyan]}Select Server Software:${NC}"
    echo -e "${colors[white]}1)${NC} Paper (Latest)"
    echo -e "${colors[white]}2)${NC} Forge (Latest)"
    echo -e "${colors[white]}3)${NC} Fabric (Latest)"
    echo -e "${colors[white]}4)${NC} Purpur (Latest)"
    echo -e "${colors[white]}5)${NC} Vanilla (Latest)"
    echo -e "${colors[white]}6)${NC} Spigot (Latest)"
    echo -e "${colors[white]}7)${NC} Bungeecord (Latest)"
    echo
    echo -n "Enter your choice (1-7): "
    read -r choice

    case $choice in
        1) SELECTED_SOFTWARE="paper";;
        2) SELECTED_SOFTWARE="forge";;
        3) SELECTED_SOFTWARE="fabric";;
        4) SELECTED_SOFTWARE="purpur";;
        5) SELECTED_SOFTWARE="vanilla";;
        6) SELECTED_SOFTWARE="spigot";;
        7) SELECTED_SOFTWARE="bungeecord";;
        *) echo -e "${colors[bold_red]}Invalid choice. Defaulting to Paper.${NC}"; SELECTED_SOFTWARE="paper";;
    esac
    
    animate_text "Selected $SELECTED_SOFTWARE server software" "bold_green"
    sleep 2
}

# Show menu options
show_menu() {
    echo -e "${colors[bold_cyan]}Available Commands:${NC}"
    echo -e "${colors[white]}1)${NC} Start Server"
    echo -e "${colors[white]}2)${NC} Stop Server"
    echo -e "${colors[white]}3)${NC} Restart Server"
    echo -e "${colors[white]}4)${NC} Create Backup"
    echo -e "${colors[white]}5)${NC} Show Server Status"
    echo -e "${colors[white]}6)${NC} View Logs"
    echo -e "${colors[white]}7)${NC} Configure Server"
    echo -e "${colors[white]}8)${NC} Exit"
    echo
    echo -e "Enter your choice: "
}

# Download and install server software
install_server() {
    animate_text "Installing $SELECTED_SOFTWARE server..." "bold_cyan"
    
    case $SELECTED_SOFTWARE in
        "paper")
            curl -o server.jar "https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/latest/downloads/paper-1.20.4-latest.jar"
            ;;
        "forge")
            curl -o installer.jar "https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.4-latest/forge-1.20.4-latest-installer.jar"
            java -jar installer.jar --installServer
            rm installer.jar
            ;;
        "fabric")
            curl -o installer.jar "https://maven.fabricmc.net/net/fabricmc/fabric-installer/latest/fabric-installer-latest.jar"
            java -jar installer.jar server -mcversion 1.20.4 -downloadMinecraft
            rm installer.jar
            ;;
        "purpur")
            curl -o server.jar "https://api.purpurmc.org/v2/purpur/1.20.4/latest/download"
            ;;
        "vanilla")
            curl -o server.jar "https://piston-data.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e594d/server.jar"
            ;;
        "spigot")
            curl -o buildtools.jar "https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar"
            java -jar buildtools.jar --rev 1.20.4
            rm buildtools.jar
            ;;
        "bungeecord")
            curl -o bungeecord.jar "https://ci.md-5.net/job/BungeeCord/lastSuccessfulBuild/artifact/bootstrap/target/BungeeCord.jar"
            ;;
    esac

    # Install plugins
    mkdir -p plugins
    animate_text "Installing Chunky plugin..." "bold_cyan"
    curl -o plugins/Chunky.jar "https://modrinth.com/plugin/chunky/versions/latest/download"
    animate_text "Installing Hibernate plugin..." "bold_cyan"
    curl -o plugins/Hibernate.jar "https://github.com/SeerMCPE/Hibernate/releases/download/v1.0.0/Hibernate-1.0.0.jar"

    animate_text "Server installation completed!" "bold_green"
}

# Configure server properties
configure_server_properties() {
    if [ ! -f "server.properties" ]; then
        cat > server.properties << EOL
#Minecraft server properties
#$(date)
enable-jmx-monitoring=false
rcon.port=25575
level-seed=
gamemode=survival
enable-command-block=false
enable-query=false
generator-settings={}
enforce-secure-profile=true
level-name=world
motd=A Minecraft Server powered by CZARACTYL
query.port=25565
pvp=true
generate-structures=true
max-chained-neighbor-updates=1000000
difficulty=easy
network-compression-threshold=256
max-tick-time=60000
require-resource-pack=false
use-native-transport=true
max-players=20
online-mode=true
enable-status=true
allow-flight=false
initial-disabled-packs=
broadcast-rcon-to-ops=true
view-distance=10
server-ip=
resource-pack-prompt=
allow-nether=true
server-port=25565
enable-rcon=false
sync-chunk-writes=true
op-permission-level=4
prevent-proxy-connections=false
hide-online-players=false
resource-pack=
entity-broadcast-range-percentage=100
simulation-distance=10
rcon.password=
player-idle-timeout=0
force-gamemode=false
rate-limit=0
hardcore=false
white-list=false
broadcast-console-to-ops=true
spawn-npcs=true
spawn-animals=true
function-permission-level=2
initial-enabled-packs=vanilla
level-type=minecraft\:normal
text-filtering-config=
spawn-monsters=true
enforce-whitelist=false
spawn-protection=16
resource-pack-sha1=
max-world-size=29999984
EOL
    fi
}

# Set server icon
set_server_icon() {
    if [ ! -f "server-icon.png" ]; then
        curl -o server-icon.png "https://example.com/your-server-icon.png"
    fi
}

# Start server function
start_server() {
    if [ ! -f "server.jar" ] && [ ! -f "bungeecord.jar" ]; then
        install_server
    fi

    configure_server_properties
    set_server_icon

    animate_text "Starting server..." "bold_green"
    
    if [ "$SELECTED_SOFTWARE" = "bungeecord" ]; then
        java -Xms${SERVER_MEMORY}M -Xmx${SERVER_MEMORY}M -jar bungeecord.jar &
    else
        java -Xms${SERVER_MEMORY}M -Xmx${SERVER_MEMORY}M -XX:+UseG1GC -XX:+ParallelRefProcEnabled \
             -XX:MaxGCPauseMillis=200 -jar server.jar nogui &
    fi

    SERVER_PID=$!
    animate_text "Server started successfully! PID: $SERVER_PID" "bold_green"
    fancy_progress_bar 3
}

# Stop server function
stop_server() {
    if [ "$SELECTED_SOFTWARE" = "bungeecord" ]; then
        kill $SERVER_PID
    else
        screen -S minecraft -X stuff "stop$(printf '\r')"
    fi
    wait $SERVER_PID 2>/dev/null
    animate_text "Server stopped." "bold_red"
    SERVER_PID=""
}

# Create backup function
create_backup() {
    backup_name="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    animate_text "Creating backup..." "bold_cyan"
    mkdir -p backups
    tar -czf "backups/$backup_name" world world_nether world_the_end plugins config
    animate_text "Backup created: $backup_name" "bold_green"
    fancy_progress_bar 2
}

# Show server status
show_server_status() {
    echo -e "${colors[bold_cyan]}Server Status:${NC}"
    echo -e "Software: $SELECTED_SOFTWARE"
    echo -e "PID: $SERVER_PID"
    echo -e "CPU: $(ps -p $SERVER_PID -o %cpu= 2>/dev/null || echo "0.00")%"
    echo -e "Memory: $(ps -p $SERVER_PID -o %mem= 2>/dev/null || echo "0.00")%"
    echo -e "Uptime: $(ps -o etime= -p $SERVER_PID 2>/dev/null || echo "00:00")"
    echo -e "Players: $(grep -c "logged in with entity id" logs/latest.log 2>/dev/null || echo "0")"
}

# Main script execution
clear_screen
select_software
show_menu

# Main loop
while true; do
    read -r choice
    case $choice in
        1) start_server ;;
        2) stop_server ;;
        3) 
            stop_server
            start_server
            ;;
        4) create_backup ;;
        5) show_server_status ;;
        6) less +G logs/latest.log ;;
        7)
            clear_screen
            select_software
            show_menu
            ;;
        8)
            animate_text "Exiting CZARACTYL..." "bold_red"
            stop_server
            exit 0
            ;;
        *)
            animate_text "Invalid option. Please try again." "bold_red"
            ;;
    esac
    echo
    show_menu
done
