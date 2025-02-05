#!/bin/bash
# install.sh

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
        PAPER_VERSION=$(curl -s https://papermc.io/api/v2/projects/paper | jq -r '.versions[-1]')
        PAPER_BUILD=$(curl -s "https://papermc.io/api/v2/projects/paper/versions/${PAPER_VERSION}/builds" | jq -r '.builds[-1].build')
        URL="https://papermc.io/api/v2/projects/paper/versions/${PAPER_VERSION}/builds/${PAPER_BUILD}/downloads/paper-${PAPER_VERSION}-${PAPER_BUILD}.jar"
        JAR_NAME="paper.jar"
        ;;
    2)
        animate_text "Installing latest Forge..." "${GREEN}"
        FORGE_VERSION=$(curl -s https://files.minecraftforge.net/net/minecraftforge/forge/promotions_slim.json | jq -r '.promos["latest-1.20.4"]')
        URL="https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.4-${FORGE_VERSION}/forge-1.20.4-${FORGE_VERSION}-installer.jar"
        JAR_NAME="forge-installer.jar"
        ;;
    3)
        animate_text "Installing latest Fabric..." "${GREEN}"
        FABRIC_VERSION=$(curl -s https://meta.fabricmc.net/v2/versions/installer | jq -r '.[0].version')
        URL="https://maven.fabricmc.net/net/fabricmc/fabric-installer/${FABRIC_VERSION}/fabric-installer-${FABRIC_VERSION}.jar"
        JAR_NAME="fabric-installer.jar"
        ;;
    4)
        animate_text "Installing latest Sponge..." "${GREEN}"
        SPONGE_VERSION=$(curl -s https://repo.spongepowered.org/maven/org/spongepowered/spongevanilla/maven-metadata.xml | grep -oP '(?<=<release>).*?(?=</release>)')
        URL="https://repo.spongepowered.org/maven/org/spongepowered/spongevanilla/${SPONGE_VERSION}/spongevanilla-${SPONGE_VERSION}.jar"
        JAR_NAME="sponge.jar"
        ;;
    5)
        animate_text "Installing latest BungeeCord..." "${GREEN}"
        URL="https://ci.md-5.net/job/BungeeCord/lastSuccessfulBuild/artifact/bootstrap/target/BungeeCord.jar"
        JAR_NAME="bungeecord.jar"
        ;;
    6)
        animate_text "Installing latest Bedrock..." "${GREEN}"
        BEDROCK_VERSION=$(curl -s https://www.minecraft.net/en-us/download/server/bedrock | grep -oP '(?<=bedrock-server-).*?(?=.zip)')
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
        java -jar fabric-installer.jar server -downloadMinecraft
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

# Create plugins folder and download Chunky plugin
mkdir -p plugins
echo -e "${CYAN}Downloading Chunky plugin...${NC}"
curl -L -o plugins/Chunky-Bukkit-1.4.28.jar "https://cdn.modrinth.com/data/fALzjamp/versions/ytBhnGfO/Chunky-Bukkit-1.4.28.jar"

animate_text "Installation complete! Server is ready to start." "${GREEN}${BOLD}"
