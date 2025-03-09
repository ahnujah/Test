#!/bin/bash

# AuraNodes Minecraft Server Installer & Launcher
# This script installs and runs various Minecraft server types
# Compatible with Pterodactyl Panel

# ANSI color codes for beautiful output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Function to display animated text
animate_text() {
    text="$1"
    color="$2"
    sleep_time="${3:-0.03}"
    
    for (( i=0; i<${#text}; i++ )); do
        echo -ne "${color}${text:$i:1}${NC}"
        sleep $sleep_time
    done
    echo
}

# Function to display a fancy progress bar
show_progress() {
    local duration=$1
    local message=$2
    local width=50
    local bar_char="█"
    local empty_char="░"
    local colors=("${RED}" "${YELLOW}" "${GREEN}" "${CYAN}" "${BLUE}" "${PURPLE}")
    
    echo -ne "${message} "
    
    for ((i=0; i<=width; i++)); do
        local color_index=$((i % 6))
        local percent=$((i*100/width))
        
        # Calculate how many bar characters to show
        local bar_count=$i
        local empty_count=$((width-i))
        
        echo -ne "\r${message} ["
        
        # Print the colored progress bar
        for ((j=0; j<bar_count; j++)); do
            local color_j=$((j % 6))
            echo -ne "${colors[$color_j]}${bar_char}"
        done
        
        # Print the empty part of the bar
        for ((j=0; j<empty_count; j++)); do
            echo -ne "${empty_char}"
        done
        
        echo -ne "] ${percent}%"
        
        sleep $(echo "scale=3; $duration/$width" | bc)
    done
    
    echo -e "\r${message} [${GREEN}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${bar_char}${NC}] ${GREEN}100%${NC}"
}

# Function to display the banner
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
    ___                      _   __           __         
   /   | __  __________     / | / /___  ____/ /__  _____
  / /| |/ / / / ___/ _ \   /  |/ / __ \/ __  / _ \/ ___/
 / ___ / /_/ / /  /  __/  / /|  / /_/ / /_/ /  __(__  ) 
/_/  |_\__,_/_/   \___/  /_/ |_/\____/\__,_/\___/____/  
                                                         
EOF
    echo -e "${NC}"
    animate_text "Ultimate Minecraft Server Management" "${YELLOW}" 0.02
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}Version: 2.1.0 | Optimized for Pterodactyl${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo
}

# Function to check and install dependencies
check_dependencies() {
    local dependencies=("curl" "wget" "unzip" "java" "screen" "bc")
    local missing_deps=()
    
    for dep in "${dependencies[@]}"; do
        if ! command -v $dep &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${YELLOW}Installing required dependencies: ${missing_deps[*]}${NC}"
        if command -v apt-get &> /dev/null; then
            apt-get update -qq
            apt-get install -y -qq "${missing_deps[@]}"
        elif command -v yum &> /dev/null; then
            yum install -y -q "${missing_deps[@]}"
        else
            echo -e "${RED}Unsupported package manager. Please install dependencies manually.${NC}"
            exit 1
        fi
    fi
}

# Function to detect Java version and set appropriate flags
setup_java() {
    # Get Java version
    if command -v java &> /dev/null; then
        JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
        echo -e "${BLUE}Detected Java version: $JAVA_VERSION${NC}"
    else
        echo -e "${RED}Java not found. Please install Java 8 or higher.${NC}"
        exit 1
    fi
    
    # Set memory allocation
    if [ -z "$MEMORY" ]; then
        TOTAL_MEMORY=$(free -m | awk '/^Mem:/{print $2}')
        if [ "$TOTAL_MEMORY" -gt 8000 ]; then
            MEMORY="4G"
        elif [ "$TOTAL_MEMORY" -gt 4000 ]; then
            MEMORY="2G"
        elif [ "$TOTAL_MEMORY" -gt 2000 ]; then
            MEMORY="1G"
        else
            MEMORY="512M"
        fi
    fi
    
    echo -e "${GREEN}Memory allocation set to: $MEMORY${NC}"
    
    # Aikar's optimized JVM flags
    JAVA_FLAGS=(
        "-XX:+UseG1GC"
        "-XX:+ParallelRefProcEnabled"
        "-XX:MaxGCPauseMillis=200"
        "-XX:+UnlockExperimentalVMOptions"
        "-XX:+DisableExplicitGC"
        "-XX:+AlwaysPreTouch"
        "-XX:G1NewSizePercent=30"
        "-XX:G1MaxNewSizePercent=40"
        "-XX:G1HeapRegionSize=8M"
        "-XX:G1ReservePercent=20"
        "-XX:G1HeapWastePercent=5"
        "-XX:G1MixedGCCountTarget=4"
        "-XX:InitiatingHeapOccupancyPercent=15"
        "-XX:G1MixedGCLiveThresholdPercent=90"
        "-XX:G1RSetUpdatingPauseTimePercent=5"
        "-XX:SurvivorRatio=32"
        "-XX:+PerfDisableSharedMem"
        "-XX:MaxTenuringThreshold=1"
        "-Dusing.aikars.flags=https://mcflags.emc.gs"
        "-Daikars.new.flags=true"
    )
}

# Function to download and install server software
install_server() {
    local server_type=$1
    local mc_version=${2:-"latest"}
    
    echo -e "${CYAN}Installing $server_type server (Minecraft $mc_version)...${NC}"
    
    case $server_type in
        "paper")
            if [ "$mc_version" == "latest" ]; then
                mc_version="1.20.4"
            fi
            
            # Get latest build for the specified version
            build_info=$(curl -s "https://api.papermc.io/v2/projects/paper/versions/$mc_version")
            latest_build=$(echo $build_info | grep -o '"builds":\[[0-9,]*\]' | grep -o '[0-9]*' | tail -1)
            
            if [ -z "$latest_build" ]; then
                echo -e "${RED}Failed to get latest build for Paper $mc_version${NC}"
                exit 1
            fi
            
            download_url="https://api.papermc.io/v2/projects/paper/versions/$mc_version/builds/$latest_build/downloads/paper-$mc_version-$latest_build.jar"
            wget -O server.jar "$download_url"
            
            echo "paper" > .server-type
            ;;
            
        "forge")
            if [ "$mc_version" == "latest" ]; then
                mc_version="1.20.4"
            fi
            
            # Get latest Forge version for the specified Minecraft version
            forge_version="49.0.14" # This would ideally be fetched dynamically
            
            download_url="https://maven.minecraftforge.net/net/minecraftforge/forge/$mc_version-$forge_version/forge-$mc_version-$forge_version-installer.jar"
            wget -O forge-installer.jar "$download_url"
            
            show_progress 3 "Installing Forge"
            java -jar forge-installer.jar --installServer
            
            # Clean up installer
            rm forge-installer.jar
            
            # Find the forge jar
            forge_jar=$(find . -name "forge-$mc_version-$forge_version*.jar" | grep -v installer | head -1)
            if [ -z "$forge_jar" ]; then
                forge_jar=$(find . -name "forge-*.jar" | grep -v installer | head -1)
            fi
            
            if [ -z "$forge_jar" ]; then
                echo -e "${RED}Failed to find Forge server jar${NC}"
                exit 1
            fi
            
            echo "forge" > .server-type
            echo "$forge_jar" > .forge-jar
            ;;
            
        "fabric")
            if [ "$mc_version" == "latest" ]; then
                mc_version="1.20.4"
            fi
            
            # Download Fabric installer
            wget -O fabric-installer.jar "https://maven.fabricmc.net/net/fabricmc/fabric-installer/0.11.2/fabric-installer-0.11.2.jar"
            
            show_progress 3 "Installing Fabric"
            java -jar fabric-installer.jar server -mcversion $mc_version -downloadMinecraft
            
            # Clean up installer
            rm fabric-installer.jar
            
            echo "fabric" > .server-type
            ;;
            
        "purpur")
            if [ "$mc_version" == "latest" ]; then
                mc_version="1.20.4"
            fi
            
            download_url="https://api.purpurmc.org/v2/purpur/$mc_version/latest/download"
            wget -O server.jar "$download_url"
            
            echo "purpur" > .server-type
            ;;
            
        "spigot")
            if [ "$mc_version" == "latest" ]; then
                mc_version="1.20.4"
            fi
            
            # Download BuildTools
            wget -O BuildTools.jar "https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar"
            
            show_progress 5 "Building Spigot (this may take a while)"
            java -jar BuildTools.jar --rev $mc_version
            
            # Clean up BuildTools
            rm BuildTools.jar
            
            # Move the built jar to server.jar
            if [ -f "spigot-$mc_version.jar" ]; then
                mv "spigot-$mc_version.jar" server.jar
            else
                echo -e "${RED}Failed to build Spigot server jar${NC}"
                exit 1
            fi
            
            echo "spigot" > .server-type
            ;;
            
        "vanilla")
            if [ "$mc_version" == "latest" ]; then
                mc_version="1.20.4"
            fi
            
            # This is a simplified approach - in a real script you'd want to fetch the actual latest version
            download_url="https://piston-data.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e594d/server.jar"
            wget -O server.jar "$download_url"
            
            echo "vanilla" > .server-type
            ;;
            
        "bungeecord")
            download_url="https://ci.md-5.net/job/BungeeCord/lastSuccessfulBuild/artifact/bootstrap/target/BungeeCord.jar"
            wget -O server.jar "$download_url"
            
            echo "bungeecord" > .server-type
            ;;
            
        "velocity")
            download_url="https://api.papermc.io/v2/projects/velocity/versions/3.2.0-SNAPSHOT/builds/263/downloads/velocity-3.2.0-SNAPSHOT-263.jar"
            wget -O server.jar "$download_url"
            
            echo "velocity" > .server-type
            ;;
            
        *)
            echo -e "${RED}Unsupported server type: $server_type${NC}"
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}Server software installed successfully!${NC}"
}

# Function to install plugins
install_plugins() {
    local server_type=$(cat .server-type)
    
    # Skip plugin installation for certain server types
    if [[ "$server_type" == "vanilla" || "$server_type" == "forge" || "$server_type" == "bungeecord" || "$server_type" == "velocity" ]]; then
        echo -e "${YELLOW}Skipping plugin installation for $server_type server${NC}"
        return
    fi
    
    echo -e "${CYAN}Installing essential plugins...${NC}"
    mkdir -p plugins
    
    # Define plugins to install based on server type
    declare -A plugins
    
    # Common plugins for all supported server types
    plugins["essentialsx"]="https://github.com/EssentialsX/Essentials/releases/download/2.20.1/EssentialsX-2.20.1.jar"
    plugins["luckperms"]="https://download.luckperms.net/1515/bukkit/loader/LuckPerms-Bukkit-5.4.102.jar"
    plugins["vault"]="https://github.com/MilkBowl/Vault/releases/download/1.7.3/Vault.jar"
    
    # Paper/Spigot/Purpur specific plugins
    if [[ "$server_type" == "paper" || "$server_type" == "spigot" || "$server_type" == "purpur" ]]; then
        plugins["worldedit"]="https://dev.bukkit.org/projects/worldedit/files/latest"
        plugins["chunky"]="https://cdn.modrinth.com/data/fALzjamp/versions/ytBhnGfO/Chunky-Bukkit-1.4.28.jar"
    fi
    
    # Download each plugin
    for plugin in "${!plugins[@]}"; do
        echo -e "${BLUE}Downloading $plugin...${NC}"
        wget -q --show-progress -O "plugins/${plugin}.jar" "${plugins[$plugin]}"
    done
    
    echo -e "${GREEN}Plugins installed successfully!${NC}"
}

# Function to configure server properties
configure_server() {
    local server_type=$(cat .server-type)
    
    echo -e "${CYAN}Configuring server...${NC}"
    
    # Create server.properties for Minecraft servers
    if [[ "$server_type" != "bungeecord" && "$server_type" != "velocity" ]]; then
        if [ ! -f "server.properties" ]; then
            cat > server.properties << EOL
#Minecraft server properties
#Generated by AuraNodes
server-port=${SERVER_PORT:-25565}
motd=\\u00A7b\\u00A7lAuraNodes \\u00A78| \\u00A7fPremium Game Hosting
enable-command-block=true
spawn-protection=0
view-distance=10
simulation-distance=10
max-players=20
online-mode=true
allow-flight=true
white-list=false
difficulty=normal
gamemode=survival
EOL
        fi
    fi
    
    # Create config for BungeeCord
    if [ "$server_type" == "bungeecord" ] && [ ! -f "config.yml" ]; then
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
  host: 0.0.0.0:${SERVER_PORT:-25565}
  max_players: 500
  tab_size: 60
  force_default_server: false
EOL
    fi
    
    # Create config for Velocity
    if [ "$server_type" == "velocity" ] && [ ! -f "velocity.toml" ]; then
        cat > velocity.toml << EOL
# Velocity configuration

# The bind address for the server
bind = "0.0.0.0:${SERVER_PORT:-25565}"

# The motd for the server
motd = "&b&lAuraNodes &8| &fPremium Game Hosting"

# The maximum number of players on the server
show-max-players = 500

# Whether to enable player info forwarding
player-info-forwarding-mode = "NONE"

# The forwarding secret for player info forwarding
forwarding-secret = ""

# Whether to announce server information to the proxy
announce-forge = false

# Whether to enable online mode
online-mode = true

# Whether to enable the query protocol
enable-query = false

# The port for the query protocol
query-port = 25577

# Whether to enable compression
enable-compression = true

# The threshold for compression
compression-threshold = 256

# The level of compression
compression-level = 3

# The timeout for connections
connection-timeout = 5000

# The timeout for read operations
read-timeout = 30000

# The servers to connect to
[servers]
  lobby = "127.0.0.1:25566"
  survival = "127.0.0.1:25567"
EOL
    fi
    
    # Accept EULA
    echo "eula=true" > eula.txt
    
    # Create server icon if it doesn't exist
    if [ ! -f "server-icon.png" ]; then
        echo -e "${BLUE}Downloading server icon...${NC}"
        wget -q -O server-icon.png "https://i.imgur.com/4KbNMKs.png"
    fi
    
    echo -e "${GREEN}Server configured successfully!${NC}"
}

# Function to start the server
start_server() {
    local server_type=$(cat .server-type)
    
    echo -e "${CYAN}Starting $server_type server...${NC}"
    
    # Set memory allocation
    if [ -z "$MEMORY" ]; then
        MEMORY="1G"
    fi
    
    # Start the server based on type
    case $server_type in
        "paper"|"spigot"|"purpur"|"vanilla")
            java -Xms512M -Xmx$MEMORY ${JAVA_FLAGS[@]} -jar server.jar nogui
            ;;
        "forge")
            forge_jar=$(cat .forge-jar)
            if [ -f "user_jvm_args.txt" ]; then
                java -Xms512M -Xmx$MEMORY ${JAVA_FLAGS[@]} @user_jvm_args.txt @libraries/net/minecraftforge/forge/*/unix_args.txt nogui
            else
                java -Xms512M -Xmx$MEMORY ${JAVA_FLAGS[@]} -jar $forge_jar nogui
            fi
            ;;
        "fabric")
            if [ -f "fabric-server-launch.jar" ]; then
                java -Xms512M -Xmx$MEMORY ${JAVA_FLAGS[@]} -jar fabric-server-launch.jar nogui
            else
                java -Xms512M -Xmx$MEMORY ${JAVA_FLAGS[@]} -jar server.jar nogui
            fi
            ;;
        "bungeecord"|"velocity")
            java -Xms512M -Xmx$MEMORY -jar server.jar
            ;;
        *)
            echo -e "${RED}Unknown server type: $server_type${NC}"
            exit 1
            ;;
    esac
}

# Main function
main() {
    show_banner
    check_dependencies
    setup_java
    
    # Check if server is already installed
    if [ -f ".server-type" ]; then
        echo -e "${GREEN}Server already installed: $(cat .server-type)${NC}"
    else
        # Display server type selection menu
        echo -e "${CYAN}Select server software to install:${NC}"
        echo -e "${WHITE}1)${NC} ${GREEN}Paper${NC} - High performance fork with plugin support (Recommended)"
        echo -e "${WHITE}2)${NC} ${YELLOW}Forge${NC} - For modded Minecraft"
        echo -e "${WHITE}3)${NC} ${BLUE}Fabric${NC} - Lightweight, modular mod loader"
        echo -e "${WHITE}4)${NC} ${PURPLE}Purpur${NC} - Fork of Paper with additional features"
        echo -e "${WHITE}5)${NC} ${WHITE}Vanilla${NC} - Official Minecraft server"
        echo -e "${WHITE}6)${NC} ${RED}Spigot${NC} - Optimized CraftBukkit fork"
        echo -e "${WHITE}7)${NC} ${CYAN}BungeeCord${NC} - Proxy server for connecting multiple servers"
        echo -e "${WHITE}8)${NC} ${BLUE}Velocity${NC} - Modern, high-performance proxy server"
        echo
        
        # Get server type selection
        read -p "Enter your choice (1-8): " choice
        
        case $choice in
            1) server_type="paper";;
            2) server_type="forge";;
            3) server_type="fabric";;
            4) server_type="purpur";;
            5) server_type="vanilla";;
            6) server_type="spigot";;
            7) server_type="bungeecord";;
            8) server_type="velocity";;
            *) echo -e "${RED}Invalid choice. Defaulting to Paper.${NC}"; server_type="paper";;
        esac
        
        # Get Minecraft version
        echo
        echo -e "${CYAN}Enter Minecraft version (e.g., 1.20.4) or press Enter for latest:${NC}"
        read -p "> " mc_version
        
        if [ -z "$mc_version" ]; then
            mc_version="latest"
        fi
        
        # Install server
        install_server "$server_type" "$mc_version"
        
        # Install plugins
        install_plugins
    fi
    
    # Configure server
    configure_server
    
    # Start server
    start_server
}

# Execute main function
main
