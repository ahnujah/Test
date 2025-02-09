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
   ▄████████  ▄███████▄     ▄████████    ▄████████    ▄████████  ▄████████  ▄████████    ▄█     ▄██████▄     ▄█       
  ███    ███ ██▀     ▄██   ███    ███   ███    ███   ███    ███ ███    ███ ███    ███   ███    ███    ███   ███       
  ███    █▀        ▄███▀   ███    ███   ███    ███   ███    ███ ███    ███ ███    █▀    ███▌   ███    █▀    ███       
  ███         ▀█▀▄███▀▄▄   ███    ███  ▄███▄▄▄▄██▀   ███    ███ ███    ███ ███         ▄███▄  ▄███          ███       
▀███████████ ▄███▀   ▀▀ ▀█████████▀  ▀▀███▀▀▀▀▀   ▀███████████ ███    ███ ███        ▀▀███▀  ▀▀███ ████▄  ███       
         ███ ████▄     ▄   ███        ▀███████████   ███    ███ ███    ███ ███    █▄    ███    ███    ███   ███       
   ▄█    ███ ██▀    ▄██▀   ███          ███    ███   ███    ███ ███    ███ ███    ███   ███    ███    ███   ███▌    ▄ 
 ▄████████▀  ██████████   ▄████▀        ███    ███   ███    █▀  ████████▀  ████████▀    █▀     ████████▀    █████▄▄██ 
                                        ███    ███                                                          ▀         
${NC}
EOF
    echo
    animate_gradient_text "Welcome to the Ultimate Minecraft Server Management Experience" "ff0000" "00ffff" 0.01
    echo
    echo -e "${colors[bold_cyan]}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${colors[bold_cyan]}║                           CZARACTYL CONTROL PANEL                             ║${NC}"
    echo -e "${colors[bold_cyan]}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
}

# Function to select and install server software
select_and_install_software() {
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
        1) software="paper";;
        2) software="forge";;
        3) software="fabric";;
        4) software="purpur";;
        5) software="vanilla";;
        6) software="spigot";;
        7) software="bungeecord";;
        *) echo -e "${colors[bold_red]}Invalid choice. Defaulting to Paper.${NC}"; software="paper";;
    esac
    
    animate_gradient_text "Installing $software server..." "00ff00" "0000ff"
    
    case $software in
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

    fancy_progress_bar 3
    animate_gradient_text "Server software installed successfully!" "00ff00" "ffff00"
}

# Function to install plugins
install_plugins() {
    animate_gradient_text "Installing plugins..." "00ffff" "ff00ff"
    mkdir -p plugins
    curl -o plugins/Chunky.jar "https://modrinth.com/plugin/chunky/versions/latest/download"
    curl -o plugins/Hibernate.jar "https://github.com/SeerMCPE/Hibernate/releases/download/v1.0.0/Hibernate-1.0.0.jar"
    fancy_progress_bar 2
    animate_gradient_text "Plugins installed successfully!" "00ff00" "ffff00"
}

# Function to configure server properties
configure_server_properties() {
    animate_gradient_text "Configuring server properties..." "ffff00" "00ffff"
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
    fancy_progress_bar 2
    animate_gradient_text "Server properties configured successfully!" "00ff00" "ffff00"
}

# Main script execution
clear_screen
select_and_install_software
install_plugins
configure_server_properties

animate_gradient_text "CZARACTYL setup completed successfully!" "ff00ff" "00ffff"
echo -e "${colors[bold_green]}Your Minecraft server is now ready to start.${NC}"
echo -e "${colors[bold_yellow]}Run 'java -jar server.jar' to start your server.${NC}"
