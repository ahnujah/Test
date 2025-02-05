#!/bin/bash
# install.sh

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Function to display animated text
animate_text() {
    text="$1"
    color="$2"
    for (( i=0; i<${#text}; i++ )); do
        echo -ne "${color}${text:$i:1}${NC}"
        sleep 0.01
    done
    echo
}

# Clear screen and show banner
clear
echo -e "${CYAN}${BOLD}"
cat << "EOF"
 ██████╗███████╗ █████╗ ██████╗  █████╗  ██████╗████████╗██╗   ██╗██╗     
██╔════╝╚══███╔╝██╔══██╗██╔══██╗██╔══██╗██╔════╝╚══██╔══╝╚██╗ ██╔╝██║     
██║       ███╔╝ ███████║██████╔╝███████║██║        ██║    ╚████╔╝ ██║     
██║      ███╔╝  ██╔══██║██╔══██╗██╔══██║██║        ██║     ╚██╔╝  ██║     
╚██████╗███████╗██║  ██║██║  ██║██║  ██║╚██████╗   ██║      ██║   ███████╗
 ╚═════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝   ╚═╝      ╚═╝   ╚══════╝
EOF
echo -e "${NC}"

animate_text "Welcome to Czaractyl Server Installation" "${YELLOW}${BOLD}"
echo -e "${MAGENTA}${BOLD}==========================================================================${NC}"

# Function to download with progress
download_with_progress() {
    echo -e "${CYAN}Downloading server files...${NC}"
    curl -#L "$1" -o "$2"
}

# Function to fetch PaperMC versions
fetch_paper_versions() {
    curl -s "https://gist.githubusercontent.com/osipxd/6119732e30059241c2192c4a8d2218d9/raw/b3b0d5871333f087eb97df84eaa54c93e3fe9aad/paper-versions.json" | jq -r '.versions | keys[]'
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

# Version selection
if [ "$choice" -eq 1 ]; then
    echo -e "\n${GREEN}Available Paper versions:${NC}"
    VERSIONS=($(fetch_paper_versions))
    for i in "${!VERSIONS[@]}"; do 
        echo -e "${CYAN}[$((i+1))] ${VERSIONS[$i]}${NC}"
    done
    echo -e "${CYAN}[0] Custom version${NC}"

    read -p "$(echo -e ${YELLOW}"Enter your choice (0-${#VERSIONS[@]}): "${NC})" version_choice

    if [ "$version_choice" -eq 0 ]; then
        read -p "$(echo -e ${YELLOW}"Enter custom version: "${NC})" SERVER_VERSION
    else
        SERVER_VERSION="${VERSIONS[$((version_choice-1))]}"
    fi
else
    read -p "$(echo -e ${YELLOW}"Enter Minecraft version (e.g., 1.20.4): "${NC})" SERVER_VERSION
fi

echo -e "${MAGENTA}${BOLD}==========================================================================${NC}"
animate_text "Installing Minecraft version: $SERVER_VERSION" "${CYAN}"
echo -e "${MAGENTA}${BOLD}==========================================================================${NC}"

case $choice in
    1)
        animate_text "Installing Paper..." "${GREEN}"
        PAPER_JSON=$(curl -s "https://gist.githubusercontent.com/osipxd/6119732e30059241c2192c4a8d2218d9/raw/b3b0d5871333f087eb97df84eaa54c93e3fe9aad/paper-versions.json")
        URL=$(echo $PAPER_JSON | jq -r ".versions[\"$SERVER_VERSION\"]")
        JAR_NAME="paper.jar"
        ;;
    2)
        animate_text "Installing Forge..." "${GREEN}"
        BUILD_NUMBER=$(curl -s "https://files.minecraftforge.net/net/minecraftforge/forge/promotions_slim.json" | jq -r --arg MC_VERSION "$SERVER_VERSION" '.promos | to_entries[] | select(.key | startswith($MC_VERSION)) | .value' | head -n 1)
        URL="https://maven.minecraftforge.net/net/minecraftforge/forge/${SERVER_VERSION}-${BUILD_NUMBER}/forge-${SERVER_VERSION}-${BUILD_NUMBER}-installer.jar"
        JAR_NAME="forge-installer.jar"
        ;;
    3)
        animate_text "Installing Fabric..." "${GREEN}"
        URL="https://maven.fabricmc.net/net/fabricmc/fabric-installer/0.11.0/fabric-installer-0.11.0.jar"
        JAR_NAME="fabric-installer.jar"
        ;;
    4)
        animate_text "Installing Sponge..." "${GREEN}"
        URL="https://repo.spongepowered.org/maven/org/spongepowered/spongevanilla/${SERVER_VERSION}/spongevanilla-${SERVER_VERSION}.jar"
        JAR_NAME="sponge.jar"
        ;;
    5)
        animate_text "Installing BungeeCord..." "${GREEN}"
        URL="https://ci.md-5.net/job/BungeeCord/lastSuccessfulBuild/artifact/bootstrap/target/BungeeCord.jar"
        JAR_NAME="bungeecord.jar"
        ;;
    6)
        animate_text "Installing Bedrock..." "${GREEN}"
        URL="https://minecraft.azureedge.net/bin-linux/bedrock-server-${SERVER_VERSION}.zip"
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
if [ $(stat -f%z "$JAR_NAME" 2>/dev/null || stat -c%s "$JAR_NAME" 2>/dev/null) -lt 1000000 ]; then
    echo -e "${RED}Error: $JAR_NAME is too small, download may have failed${NC}"
    rm "$JAR_NAME"
    exit 1
fi

# Handle specific installation steps
case $choice in
    2) # Forge
        java -jar forge-installer.jar --installServer
        rm forge-installer.jar
        JAR_NAME=$(ls forge-*-universal.jar)
        ;;
    3) # Fabric
        java -jar fabric-installer.jar server -mcversion $SERVER_VERSION -downloadMinecraft
        rm fabric-installer.jar
        JAR_NAME="fabric-server-launch.jar"
        ;;
    6) # Bedrock
        unzip -o bedrock-server.zip
        rm bedrock-server.zip
        chmod +x bedrock_server
        JAR_NAME="bedrock_server"
        ;;
esac

# Rename the final jar to server.jar (except for Bedrock)
if [ "$choice" -ne 6 ]; then
    mv "$JAR_NAME" server.jar
fi

# Create server.properties with enhanced configuration
if [ "$choice" -ne 5 ] && [ "$choice" -ne 6 ]; then
    cat > server.properties << EOL
server-port=${SERVER_PORT:-25565}
motd=\u00A7b\u00A7lCzaractyl \u00A78| \u00A7fPowered by Innovation
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
curl -o server-icon.png "https://i.postimg.cc/rwZPYnGV/IMG-20250203-221310-1.png"

# Create plugins folder and download essential plugins (for Bukkit-based servers)
if [ "$choice" -eq 1 ] || [ "$choice" -eq 4 ]; then
    mkdir -p plugins
    echo -e "${CYAN}Downloading essential plugins...${NC}"
    curl -L -o plugins/EssentialsX.jar "https://github.com/EssentialsX/Essentials/releases/download/2.19.7/EssentialsX-2.19.7.jar"
    curl -L -o plugins/LuckPerms.jar "https://ci.lucko.me/job/LuckPerms/1515/artifact/bukkit/loader/build/libs/LuckPerms-Bukkit-5.4.40.jar"
fi

animate_text "Installation complete! Server is ready to start." "${GREEN}${BOLD}"
