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
BLINK='\033[5m'

# Global variables
SERVER_PID=""
SERVER_MEMORY=1024
SELECTED_SOFTWARE=""

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
${BLINK}${BOLD}${colors[bold_cyan]}
   ▄████████  ▄███████▄     ▄████████    ▄████████    ▄████████  ▄████████  ▄████████     ███        ▄█       
  ███    ███ ██▀     ▄██   ███    ███   ███    ███   ███    ███ ███    ███ ███    ███ ▀█████████▄   ███       
  ███    █▀        ▄███▀   ███    ███   ███    ███   ███    ███ ███    ███ ███    █▀     ▀███▀▀██   ███       
  ███         ▀█▀▄███▀▄▄   ███    ███  ▄███▄▄▄▄██▀   ███    ███ ███    ███ ███            ███   ▀   ███       
▀███████████ ▄███▀   ▀▀ ▀█████████▀  ▀▀███▀▀▀▀▀   ▀███████████ ███    ███ ███            ███       ███       
         ███ ████▄     ▄   ███        ▀███████████   ███    ███ ███    ███ ███    █▄      ███       ███       
   ▄█    ███ ██▀    ▄██▀   ███          ███    ███   ███    ███ ███    ███ ███    ███     ███       ███▌    ▄ 
 ▄████████▀  ██████████   ▄████▀        ███    ███   ███    █▀  ████████▀  ████████▀     ▄████▀     █████▄▄██ 
                                        ███    ███                                                   ▀         
${NC}
EOF
    echo
    animate_gradient_text "Welcome to the Next Generation of Minecraft Server Management" "ff0000" "00ffff" 0.01
    echo
    echo -e "${colors[bold_cyan]}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${colors[bold_cyan]}║                           CZARACTYL CONTROL PANEL                             ║${NC}"
    echo -e "${colors[bold_cyan]}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
}

# Show software selection menu and download immediately
select_and_download_software() {
    echo -e "${colors[bold_cyan]}Select Server Software:${NC}"
    echo -e "${colors[white]}1)${NC} ${colors[bold_green]}Paper${NC} (Latest) - High performance fork of Spigot"
    echo -e "${colors[white]}2)${NC} ${colors[bold_yellow]}Forge${NC} (Latest) - Mod support for vanilla Minecraft"
    echo -e "${colors[white]}3)${NC} ${colors[bold_blue]}Fabric${NC} (Latest) - Lightweight, modular mod loader"
    echo -e "${colors[white]}4)${NC} ${colors[bold_purple]}Purpur${NC} (Latest) - Fork of Paper with additional features"
    echo -e "${colors[white]}5)${NC} ${colors[bold_white]}Vanilla${NC} (Latest) - Official Minecraft server"
    echo -e "${colors[white]}6)${NC} ${colors[bold_red]}Spigot${NC} (Latest) - Optimized CraftBukkit fork"
    echo -e "${colors[white]}7)${NC} ${colors[bold_cyan]}Bungeecord${NC} (Latest) - Proxy server for connecting multiple servers"
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
    
    animate_gradient_text "Selected $SELECTED_SOFTWARE server software" "00ff00" "0000ff"
    sleep 1
    
    # Download and install server software
    animate_gradient_text "Downloading $SELECTED_SOFTWARE server..." "00ffff" "ff00ff"
    
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

    # Cool download animation
    for i in {1..10}; do
        echo -ne "${colors[bold_cyan]}Downloading${NC} ${colors[bold_yellow]}[${NC}"
        for ((j=0; j<i; j++)); do echo -ne "▓"; done
        for ((j=i; j<10; j++)); do echo -ne "░"; done
        echo -ne "${colors[bold_yellow]}]${NC}\r"
        sleep 0.5
    done
    echo

    # Install plugins
    mkdir -p plugins
    animate_gradient_text "Installing Chunky plugin..." "00ff00" "00ffff"
    curl -o plugins/Chunky.jar "https://modrinth.com/plugin/chunky/versions/latest/download"
    animate_gradient_text "Installing Hibernate plugin..." "00ffff" "ff00ff"
    curl -o plugins/Hibernate.jar "https://github.com/SeerMCPE/Hibernate/releases/download/v1.0.0/Hibernate-1.0.0.jar"

    animate_gradient_text "Server installation completed!" "00ff00" "ffff00"
    fancy_progress_bar 3
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
        select_and_download_software
    fi

    configure_server_properties
    set_server_icon

    animate_gradient_text "Starting server..." "00ff00" "ffff00"
    
    if [ "$SELECTED_SOFTWARE" = "bungeecord" ]; then
        java -Xms${SERVER_MEMORY}M -Xmx${SERVER_MEMORY}M -jar bungeecord.jar &
    else
        java -Xms${SERVER_MEMORY}M -Xmx${SERVER_MEMORY}M -XX:+UseG1GC -XX:+ParallelRefProcEnabled \
             -XX:MaxGCPauseMillis=200 -jar server.jar nogui &
    fi

    SERVER_PID=$!
    animate_gradient_text "Server started successfully! PID: $SERVER_PID" "00ff00" "00ffff"
    fancy_progress_bar 3
}

# Stop server function
stop_server() {
    if [ -n "$SERVER_PID" ]; then
        if [ "$SELECTED_SOFTWARE" = "bungeecord" ]; then
            kill $SERVER_PID
        else
            screen -S minecraft -X stuff "stop$(printf '\r')"
        fi
        wait $SERVER_PID 2>/dev/null
        animate_gradient_text "Server stopped." "ff0000" "ffff00"
        SERVER_PID=""
        fancy_progress_bar 2
    else
        animate_gradient_text "No server is currently running." "ff0000" "ffff00"
    fi
}

# Create backup function
create_backup() {
    backup_name="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    animate_gradient_text "Creating backup..." "00ffff" "ff00ff"
    mkdir -p backups
    tar -czf "backups/$backup_name" world world_nether world_the_end plugins config
    animate_gradient_text "Backup created: $backup_name" "00ff00" "ffff00"
    fancy_progress_bar 2
}

# Show server status
show_server_status() {
    echo -e "${colors[bold_cyan]}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${colors[bold_cyan]}║                               Server Status                                   ║${NC}"
    echo -e "${colors[bold_cyan]}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${colors[bold_green]}Software:${NC} $SELECTED_SOFTWARE"
    echo -e "${colors[bold_yellow]}PID:${NC} $SERVER_PID"
    echo -e "${colors[bold_blue]}CPU:${NC} $(ps -p $SERVER_PID -o %cpu= 2>/dev/null || echo "0.00")%"
    echo -e "${colors[bold_purple]}Memory:${NC} $(ps -p $SERVER_PID -o %mem= 2>/dev/null || echo "0.00")%"
    echo -e "${colors[bold_cyan]}Uptime:${NC} $(ps -o etime= -p $SERVER_PID 2>/dev/null || echo "00:00")"
    echo -e "${colors[bold_white]}Players:${NC} $(grep -c "logged in with entity id" logs/latest.log 2>/dev/null || echo "0")"
    fancy_progress_bar 2
}

# Show menu options
show_menu() {
    echo -e "${colors[bold_cyan]}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${colors[bold_cyan]}║                              Available Commands                               ║${NC}"
    echo -e "${colors[bold_cyan]}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${colors[bold_green]}1)${NC} Start Server      ${colors[bold_yellow]}2)${NC} Stop Server       ${colors[bold_blue]}3)${NC} Restart Server"
    echo -e "${colors[bold_purple]}4)${NC} Create Backup    ${colors[bold_cyan]}5)${NC} Server Status     ${colors[bold_white]}6)${NC} View Logs"
    echo -e "${colors[bold_red]}7)${NC} Exit"
    echo
    echo -e "Enter your choice: "
}

# Main script execution
clear_screen
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
            animate_gradient_text "Exiting CZARACTYL..." "ff0000" "ffff00"
            stop_server
            exit 0
            ;;
        *)
            animate_gradient_text "Invalid option. Please try again." "ff0000" "ff00ff"
            ;;
    esac
    echo
    show_menu
done
