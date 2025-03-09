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
  █████╗ ██╗   ██╗██████╗  █████╗ ███╗   ██╗ ██████╗ ██████╗ ███████╗███████╗
 ██╔══██╗██║   ██║██╔══██╗██╔══██╗████╗  ██║██╔═══██╗██╔══██╗██╔════╝██╔════╝
 ███████║██║   ██║██████╔╝███████║██╔██╗ ██║██║   ██║██║  ██║█████╗  ███████╗
 ██╔══██║██║   ██║██╔══██╗██╔══██║██║╚██╗██║██║   ██║██║  ██║██╔══╝  ╚════██║
 ██║  ██║╚██████╔╝██║  ██║██║  ██║██║ ╚████║╚██████╔╝██████╔╝███████╗███████║
 ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝╚══════╝
${NC}
EOF
    echo
    animate_gradient_text "Welcome to the Ultimate Minecraft Server Management Experience" "ff0000" "00ffff" 0.01
    echo
    echo -e "${colors[bold_cyan]}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${colors[bold_cyan]}║                           AURANODES CONTROL PANEL                             ║${NC}"
    echo -e "${colors[bold_cyan]}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
}

# Function to detect installed server type
detect_server_type() {
    if [ -f ".server-type" ]; then
        SERVER_TYPE=$(cat .server-type)
        animate_gradient_text "Detected server type: $SERVER_TYPE" "00ffff" "ff00ff"
        return 0
    fi
    
    if [ -f "server.jar" ]; then
        # Try to determine server type from jar file
        if unzip -l server.jar | grep -q "com/destroystokyo/paper"; then
            SERVER_TYPE="paper-server"
            echo "$SERVER_TYPE" > .server-type
        elif unzip -l server.jar | grep -q "net/minecraft/server/MinecraftServer"; then
            SERVER_TYPE="vanilla-server"
            echo "$SERVER_TYPE" > .server-type
        elif unzip -l server.jar | grep -q "org/spongepowered"; then
            SERVER_TYPE="sponge-server"
            echo "$SERVER_TYPE" > .server-type
        elif unzip -l server.jar | grep -q "net/md_5/bungee"; then
            SERVER_TYPE="bungeecord-server"
            echo "$SERVER_TYPE" > .server-type
        else
            # Default to paper if we can't determine
            SERVER_TYPE="paper-server"
            echo "$SERVER_TYPE" > .server-type
        fi
        animate_gradient_text "Detected server type: $SERVER_TYPE" "00ffff" "ff00ff"
        return 0
    fi
    
    # If we get here, we need to select a server type
    return 1
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
            echo "paper-server" > .server-type
            ;;
        "forge")
            curl -o installer.jar "https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.4-latest/forge-1.20.4-latest-installer.jar"
            java -jar installer.jar --installServer
            rm installer.jar
            echo "forge-server" > .server-type
            ;;
        "fabric")
            curl -o installer.jar "https://maven.fabricmc.net/net/fabricmc/fabric-installer/latest/fabric-installer-latest.jar"
            java -jar installer.jar server -mcversion 1.20.4 -downloadMinecraft
            rm installer.jar
            echo "fabric-server" > .server-type
            ;;
        "purpur")
            curl -o server.jar "https://api.purpurmc.org/v2/purpur/1.20.4/latest/download"
            echo "purpur-server" > .server-type
            ;;
        "vanilla")
            curl -o server.jar "https://piston-data.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e594d/server.jar"
            echo "vanilla-server" > .server-type
            ;;
        "spigot")
            curl -o buildtools.jar "https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar"
            java -jar buildtools.jar --rev 1.20.4
            rm buildtools.jar
            echo "spigot-server" > .server-type
            ;;
        "bungeecord")
            curl -o server.jar "https://ci.md-5.net/job/BungeeCord/lastSuccessfulBuild/artifact/bootstrap/target/BungeeCord.jar"
            echo "bungeecord-server" > .server-type
            ;;
    esac

    fancy_progress_bar 3
    animate_gradient_text "Server software installed successfully!" "00ff00" "ffff00"
}

# Function to install plugins
install_plugins() {
    if [ "$SERVER_TYPE" == "bungeecord-server" ] || [ "$SERVER_TYPE" == "forge-server" ] || [ "$SERVER_TYPE" == "fabric-server" ]; then
        echo -e "${colors[bold_yellow]}Skipping plugin installation for $SERVER_TYPE${NC}"
        return
    fi
    
    animate_gradient_text "Installing plugins..." "00ffff" "ff00ff"
    mkdir -p plugins
    
    # Download essential plugins
    echo -e "${colors[cyan]}Downloading Chunky (world pre-generator)...${NC}"
    curl -s -L -o plugins/Chunky.jar "https://cdn.modrinth.com/data/fALzjamp/versions/ytBhnGfO/Chunky-Bukkit-1.4.28.jar"
    
    echo -e "${colors[cyan]}Downloading EssentialsX (basic server commands)...${NC}"
    curl -s -L -o plugins/EssentialsX.jar "https://github.com/EssentialsX/Essentials/releases/download/2.20.1/EssentialsX-2.20.1.jar"
    
    echo -e "${colors[cyan]}Downloading LuckPerms (permissions management)...${NC}"
    curl -s -L -o plugins/LuckPerms.jar "https://download.luckperms.net/1515/bukkit/loader/LuckPerms-Bukkit-5.4.102.jar"
    
    fancy_progress_bar 2
    animate_gradient_text "Plugins installed successfully!" "00ff00" "ffff00"
}

# Function to configure server properties
configure_server_properties() {
    if [ "$SERVER_TYPE" == "bungeecord-server" ]; then
        echo -e "${colors[bold_yellow]}Configuring BungeeCord config.yml instead of server.properties${NC}"
        if [ ! -f "config.yml" ]; then
            cat > config.yml << EOL
server_connect_timeout: 5000
listeners:
- query_port: 25577
  motd: '&b&lAuraNodes &8| &fPremium Game Hosting'
  tab_list: GLOBAL_PING
  query_enabled: false
  proxy_protocol: false
  forced_hosts:
    pvp.md-5.net: pvp
  ping_passthrough: false
  priorities:
  - lobby
  bind_local_address: true
  host: 0.0.0.0:25565
  max_players: 500
  tab_size: 60
  force_default_server: false
remote_ping_cache: -1
network_compression_threshold: 256
permissions:
  default:
  - bungeecord.command.server
  - bungeecord.command.list
  admin:
  - bungeecord.command.alert
  - bungeecord.command.end
  - bungeecord.command.ip
  - bungeecord.command.reload
EOL
        fi
        return
    fi
    
    if [ "$SERVER_TYPE" == "bedrock-server" ]; then
        echo -e "${colors[bold_yellow]}Configuring Bedrock server.properties${NC}"
        if [ ! -f "server.properties" ]; then
            cat > server.properties << EOL
server-name=AuraNodes Bedrock Server
gamemode=survival
difficulty=easy
allow-cheats=false
max-players=20
online-mode=true
white-list=false
server-port=19132
server-portv6=19133
view-distance=32
tick-distance=4
player-idle-timeout=30
max-threads=8
level-name=Bedrock Level
level-seed=
default-player-permission-level=member
texturepack-required=false
content-log-file-enabled=false
compression-threshold=1
server-authoritative-movement=server-auth
player-movement-score-threshold=20
player-movement-action-direction-threshold=0.85
player-movement-distance-threshold=0.3
player-movement-duration-threshold-in-ms=500
correct-player-movement=false
EOL
        fi
        return
    fi
    
    animate_gradient_text "Configuring server properties..." "ffff00" "00ffff"
    if [ ! -f "server.properties" ]; then
        cat > server.properties << EOL
#Minecraft server properties
#$(date)
enable-jmx-monitoring=false
rcon.port=25575
level-seed=
gamemode=survival
enable-command-block=true
generator-settings={}
enforce-secure-profile=true
level-name=world
motd=\u00A7b\u00A7lAuraNodes \u00A78| \u00A7fPremium Game Hosting
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
allow-flight=true
initial-disabled-packs=
broadcast-rcon-to-ops=true
view-distance=10
server-ip=
resource-pack-prompt=
allow-nether=true
server-port=${SERVER_PORT:-25565}
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
spawn-protection=0
resource-pack-sha1=
max-world-size=29999984
EOL
    fi
    fancy_progress_bar 2
    animate_gradient_text "Server properties configured successfully!" "00ff00" "ffff00"
}

# Function to accept EULA
accept_eula() {
    if [ ! -f "eula.txt" ] || ! grep -q "eula=true" eula.txt; then
        animate_gradient_text "Accepting Minecraft EULA..." "ffff00" "00ffff"
        echo "eula=true" > eula.txt
        fancy_progress_bar 1
        animate_gradient_text "EULA accepted!" "00ff00" "ffff00"
    fi
}

# Function to start the server
start_server() {
    animate_gradient_text "Starting $SERVER_TYPE..." "00ffff" "ff00ff"
    
    # Set memory allocation
    MEMORY=${MEMORY:-1024M}
    
    # Optimized Java flags for better performance
    JAVA_FLAGS="-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true"
    
    case $SERVER_TYPE in
        "bedrock-server")
            echo -e "${colors[bold_green]}Starting Bedrock server...${NC}"
            LD_LIBRARY_PATH=. ./bedrock_server
            ;;
        "paper-server"|"purpur-server"|"spigot-server"|"vanilla-server")
            echo -e "${colors[bold_green]}Starting Java server with optimized settings...${NC}"
            java -Xms${MEMORY} -Xmx${MEMORY} ${JAVA_FLAGS} -jar server.jar nogui
            ;;
        "forge-server")
            echo -e "${colors[bold_green]}Starting Forge server...${NC}"
            java -Xms${MEMORY} -Xmx${MEMORY} ${JAVA_FLAGS} @user_jvm_args.txt @libraries/net/minecraftforge/forge/*/unix_args.txt nogui
            ;;
        "fabric-server")
            echo -e "${colors[bold_green]}Starting Fabric server...${NC}"
            java -Xms${MEMORY} -Xmx${MEMORY} ${JAVA_FLAGS} -jar server.jar nogui
            ;;
        "bungeecord-server")
            echo -e "${colors[bold_green]}Starting BungeeCord server...${NC}"
            java -Xms${MEMORY} -Xmx${MEMORY} -jar server.jar
            ;;
        *)
            echo -e "${colors[bold_red]}Unknown server type: $SERVER_TYPE${NC}"
            echo -e "${colors[bold_yellow]}Attempting to start with default Java command...${NC}"
            java -Xms${MEMORY} -Xmx${MEMORY} -jar server.jar nogui
            ;;
    esac
}

# Main script execution
clear_screen

# Check if server is already installed
if detect_server_type; then
    echo -e "${colors[bold_green]}Server already installed.${NC}"
else
    # If not installed, run installation
    select_and_install_software
fi

# Install plugins if needed
install_plugins

# Configure server properties
configure_server_properties

# Accept EULA
accept_eula

# Final message before starting
animate_gradient_text "AuraNodes setup completed successfully!" "ff00ff" "00ffff"
echo -e "${colors[bold_green]}Your Minecraft server is now ready to start.${NC}"

# Start the server
start_server
