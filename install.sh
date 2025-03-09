#!/bin/bash
# install.sh for AuraNodes

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Function to display animated text
animate_text() {
    text="$1"
    color="$2"
    echo -e "${color}${text}${NC}"
}

# Clear screen and show banner
clear
echo -e "${CYAN}${BOLD}"
cat << "EOF"
  █████╗ ██╗   ██╗██████╗  █████╗ ███╗   ██╗ ██████╗ ██████╗ ███████╗███████╗
 ██╔══██╗██║   ██║██╔══██╗██╔══██╗████╗  ██║██╔═══██╗██╔══██╗██╔════╝██╔════╝
 ███████║██║   ██║██████╔╝███████║██╔██╗ ██║██║   ██║██║  ██║█████╗  ███████╗
 ██╔══██║██║   ██║██╔══██╗██╔══██║██║╚██╗██║██║   ██║██║  ██║██╔══╝  ╚════██║
 ██║  ██║╚██████╔╝██║  ██║██║  ██║██║ ╚████║╚██████╔╝██████╔╝███████╗███████║
 ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝╚══════╝
EOF
echo -e "${NC}"
echo -e "${YELLOW}${BOLD}Powered by AuraNodes - Premium Game Hosting${NC}"

animate_text "Welcome to AuraNodes Server Installation" "${YELLOW}${BOLD}"
echo -e "${MAGENTA}${BOLD}==========================================================================${NC}"

# Function to download with progress
download_with_progress() {
    echo -e "${CYAN}Downloading server files...${NC}"
    curl -#L "$1" -o "$2"
}

# Software selection
echo -e "${GREEN}Please choose your Minecraft server software:${NC}\n"
echo -e "${BOLD}[1]${NC} ${CYAN}Paper         ${YELLOW}(Recommended for vanilla + plugins)${NC}"
echo -e "${BOLD}[2]${NC} ${CYAN}Forge         ${YELLOW}(For modded Minecraft)${NC}"
echo -e "${BOLD}[3]${NC} ${CYAN}Fabric        ${YELLOW}(Lightweight mod loader)${NC}"
echo -e "${BOLD}[4]${NC} ${CYAN}Sponge        ${YELLOW}(Plugin API for modded servers)${NC}"
echo -e "${BOLD}[5]${NC} ${CYAN}BungeeCord    ${YELLOW}(Proxy server for multiple Minecraft servers)${NC}"
echo -e "${BOLD}[6]${NC} ${CYAN}Bedrock       ${YELLOW}(Official Minecraft Bedrock server)${NC}"
echo -e "${MAGENTA}${BOLD}==========================================================================${NC}"

read -p "$(echo -e ${YELLOW}"Enter your choice (1-6): "${NC})" choice

case $choice in
    1)
        animate_text "Installing latest Paper..." "${GREEN}"
        URL="https://api.papermc.io/v2/projects/paper/versions/1.21.4/builds/138/downloads/paper-1.21.4-138.jar"
        JAR_NAME="server.jar"
        ;;
    2)
        animate_text "Installing latest Forge..." "${GREEN}"
        FORGE_VERSION="49.0.14"
        URL="https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.4-${FORGE_VERSION}/forge-1.20.4-${FORGE_VERSION}-installer.jar"
        JAR_NAME="forge-installer.jar"
        ;;
    3)
        animate_text "Installing latest Fabric..." "${GREEN}"
        FABRIC_VERSION="0.15.7"
        URL="https://maven.fabricmc.net/net/fabricmc/fabric-installer/${FABRIC_VERSION}/fabric-installer-${FABRIC_VERSION}.jar"
        JAR_NAME="fabric-installer.jar"
        ;;
    4)
        animate_text "Installing latest Sponge..." "${GREEN}"
        SPONGE_VERSION="1.20.1-10.0.0"
        URL="https://repo.spongepowered.org/repository/maven-releases/org/spongepowered/spongevanilla/${SPONGE_VERSION}/spongevanilla-${SPONGE_VERSION}.jar"
        JAR_NAME="server.jar"
        ;;
    5)
        animate_text "Installing latest BungeeCord..." "${GREEN}"
        URL="https://ci.md-5.net/job/BungeeCord/lastSuccessfulBuild/artifact/bootstrap/target/BungeeCord.jar"
        JAR_NAME="server.jar"
        ;;
    6)
        animate_text "Installing latest Bedrock..." "${GREEN}"
        BEDROCK_VERSION="1.20.71.01"
        URL="https://minecraft.azureedge.net/bin-linux/bedrock-server-${BEDROCK_VERSION}.zip"
        JAR_NAME="bedrock-server.zip"
        ;;
    *)
        echo -e "${RED}Invalid choice. Exiting...${NC}"
        exit 1
        ;;
esac

download_with_progress "$URL" "$JAR_NAME"

# Verify download
if [ ! -f "$JAR_NAME" ]; then
    echo -e "${RED}Error: Failed to download $JAR_NAME${NC}"
    exit 1
fi

# Check file size (minimum 1MB)
filesize=$(stat -c%s "$JAR_NAME" 2>/dev/null || stat -f%z "$JAR_NAME" 2>/dev/null)
if [ -z "$filesize" ] || [ "$filesize" -lt 1000000 ]; then
    echo -e "${RED}Error: $JAR_NAME is too small or couldn't determine size, download may have failed${NC}"
    rm "$JAR_NAME"
    exit 1
fi

# Handle specific installation steps
case $choice in
    2) # Forge
        echo -e "${CYAN}Installing Forge server...${NC}"
        java -jar forge-installer.jar --installServer
        if [ $? -ne 0 ]; then
            echo -e "${RED}Forge installation failed. Please check Java version and try again.${NC}"
            exit 1
        fi
        rm forge-installer.jar
        FORGE_JAR=$(ls forge-*-universal.jar 2>/dev/null)
        if [ -z "$FORGE_JAR" ]; then
            FORGE_JAR=$(ls forge-*.jar | grep -v installer 2>/dev/null)
        fi
        if [ -z "$FORGE_JAR" ]; then
            echo -e "${RED}Could not find Forge server jar after installation.${NC}"
            exit 1
        fi
        mv "$FORGE_JAR" server.jar
        echo "forge-server" > .server-type
        ;;
    3) # Fabric
        echo -e "${CYAN}Installing Fabric server...${NC}"
        java -jar fabric-installer.jar server -downloadMinecraft
        if [ $? -ne 0 ]; then
            echo -e "${RED}Fabric installation failed. Please check Java version and try again.${NC}"
            exit 1
        fi
        rm fabric-installer.jar
        if [ -f "fabric-server-launch.jar" ]; then
            mv fabric-server-launch.jar server.jar
        else
            echo -e "${RED}Could not find Fabric server jar after installation.${NC}"
            exit 1
        fi
        echo "fabric-server" > .server-type
        ;;
    6) # Bedrock
        echo -e "${CYAN}Extracting Bedrock server...${NC}"
        unzip -o bedrock-server.zip
        if [ $? -ne 0 ]; then
            echo -e "${RED}Failed to extract Bedrock server files.${NC}"
            exit 1
        fi
        rm bedrock-server.zip
        chmod +x bedrock_server
        echo "bedrock-server" > .server-type
        ;;
    1) # Paper
        echo "paper-server" > .server-type
        ;;
    4) # Sponge
        echo "sponge-server" > .server-type
        ;;
    5) # BungeeCord
        echo "bungeecord-server" > .server-type
        ;;
esac

# Create server.properties with enhanced configuration
if [ "$choice" -ne 5 ] && [ "$choice" -ne 6 ]; then
    cat > server.properties << EOL
server-port=${SERVER_PORT:-25565}
motd=\u00A7b\u00A7lAuraNodes \u00A78| \u00A7fPremium Game Hosting
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

# Accept EULA
echo "eula=true" > eula.txt

# Download server icon
curl -s -o server-icon.png "https://i.imgur.com/4KbNMKs.png"

# Create plugins folder and download essential plugins
if [ "$choice" -eq 1 ] || [ "$choice" -eq 4 ]; then
    mkdir -p plugins
    echo -e "${CYAN}Downloading essential plugins...${NC}"
    # Chunky for world pre-generation
    curl -s -L -o plugins/Chunky-1.4.28.jar "https://cdn.modrinth.com/data/fALzjamp/versions/ytBhnGfO/Chunky-Bukkit-1.4.28.jar"
    # EssentialsX for basic server commands
    curl -s -L -o plugins/EssentialsX-2.20.1.jar "https://github.com/EssentialsX/Essentials/releases/download/2.20.1/EssentialsX-2.20.1.jar"
fi

# Create start script
if [ "$choice" -eq 6 ]; then
    # Bedrock start script
    cat > start.sh << 'EOL'
#!/bin/bash
./bedrock_server
EOL
else
    # Java start script with optimized flags
    cat > start.sh << 'EOL'
#!/bin/bash
SERVER_TYPE=$(cat .server-type)
MEMORY=${MEMORY:-1024M}

# Optimized Java flags
JAVA_FLAGS="-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true"

case $SERVER_TYPE in
    "paper-server"|"sponge-server"|"bungeecord-server")
        java -Xms${MEMORY} -Xmx${MEMORY} ${JAVA_FLAGS} -jar server.jar nogui
        ;;
    "forge-server")
        java -Xms${MEMORY} -Xmx${MEMORY} ${JAVA_FLAGS} -jar server.jar nogui
        ;;
    "fabric-server")
        java -Xms${MEMORY} -Xmx${MEMORY} ${JAVA_FLAGS} -jar server.jar nogui
        ;;
    *)
        echo "Unknown server type. Please check your installation."
        exit 1
        ;;
esac
EOL
fi

chmod +x start.sh

animate_text "Installation complete! Your AuraNodes server is ready to start." "${GREEN}${BOLD}"
echo -e "${CYAN}Run ${YELLOW}./start.sh${CYAN} to start your server.${NC}"
echo -e "${MAGENTA}${BOLD}==========================================================================${NC}"
echo -e "${YELLOW}Thank you for choosing AuraNodes for your game server hosting!${NC}"
