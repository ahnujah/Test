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
    curl -s "https://gist.githubusercontent.com/osipxd/6119732e30059241c2192c4a8d2218d9/raw/b3b0d5871333f087eb97df84eaa54c93e3fe9aad/paper-versions.json" | jq -r '.versions[]'
}

# Software selection
echo -e "${GREEN}Please choose your Minecraft server software:${NC}\n"
echo -e "${BOLD}[1]${NC} ${CYAN}Paper         ${YELLOW}(Recommended for vanilla + plugins)${NC}"
echo -e "${BOLD}[2]${NC} ${CYAN}Purpur        ${YELLOW}(Paper fork with more features)${NC}"
echo -e "${BOLD}[3]${NC} ${CYAN}Forge         ${YELLOW}(For modded Minecraft)${NC}"
echo -e "${BOLD}[4]${NC} ${CYAN}Fabric        ${YELLOW}(Lightweight mod loader)${NC}"
echo -e "${BOLD}[5]${NC} ${CYAN}Vanilla       ${YELLOW}(Official Minecraft server)${NC}"
echo -e "${MAGENTA}${BOLD}==========================================================================${NC}"

read -p "$(echo -e ${YELLOW}"Enter your choice (1-5): "${NC})" choice

# Version selection
echo -e "\n${GREEN}Available Minecraft versions:${NC}"
VERSIONS=($(fetch_paper_versions))
for i in "${!VERSIONS[@]}"; do 
    echo -e "${CYAN}[$((i+1))] ${VERSIONS[$i]}${NC}"
done
echo -e "${CYAN}[0] Custom version${NC}"

read -p "$(echo -e ${YELLOW}"Enter your choice (0-${#VERSIONS[@]}): "${NC})" version_choice

if [ "$version_choice" -eq 0 ]; then
    read -p "$(echo -e ${YELLOW}"Enter custom version: "${NC})" MC_VERSION
else
    MC_VERSION="${VERSIONS[$((version_choice-1))]}"
fi

echo -e "${MAGENTA}${BOLD}==========================================================================${NC}"
animate_text "Installing Minecraft version: $MC_VERSION" "${CYAN}"
echo -e "${MAGENTA}${BOLD}==========================================================================${NC}"

case $choice in
    1)
        animate_text "Installing Paper..." "${GREEN}"
        PAPER_BUILD=$(curl -s "https://papermc.io/api/v2/projects/paper/versions/${MC_VERSION}" | jq -r '.builds[-1]')
        download_with_progress "https://papermc.io/api/v2/projects/paper/versions/${MC_VERSION}/builds/${PAPER_BUILD}/downloads/paper-${MC_VERSION}-${PAPER_BUILD}.jar" "server.jar"
        ;;
    2)
        animate_text "Installing Purpur..." "${GREEN}"
        download_with_progress "https://api.purpurmc.org/v2/purpur/${MC_VERSION}/latest/download" "server.jar"
        ;;
    3)
        animate_text "Installing Forge..." "${GREEN}"
        FORGE_VERSION=$(curl -s "https://files.minecraftforge.net/net/minecraftforge/forge/promotions_slim.json" | jq -r --arg MC_VERSION "$MC_VERSION" '.promos | to_entries[] | select(.key | startswith($MC_VERSION)) | .value' | head -n 1)
        download_with_progress "https://maven.minecraftforge.net/net/minecraftforge/forge/${MC_VERSION}-${FORGE_VERSION}/forge-${MC_VERSION}-${FORGE_VERSION}-installer.jar" "forge-installer.jar"
        java -jar forge-installer.jar --installServer
        rm forge-installer.jar
        mv forge-*-universal.jar server.jar
        ;;
    4)
        animate_text "Installing Fabric..." "${GREEN}"
        FABRIC_VERSION=$(curl -s https://meta.fabricmc.net/v2/versions/loader/${MC_VERSION} | jq -r '.[0].loader.version')
        download_with_progress "https://meta.fabricmc.net/v2/versions/loader/${MC_VERSION}/${FABRIC_VERSION}/0.11.2/server/jar" "server.jar"
        ;;
    5)
        animate_text "Installing Vanilla..." "${GREEN}"
        MANIFEST_URL="https://launchermeta.mojang.com/mc/game/version_manifest.json"
        VERSION_URL=$(curl -s $MANIFEST_URL | jq -r --arg VERSION "$MC_VERSION" '.versions[] | select(.id == $VERSION) | .url')
        DOWNLOAD_URL=$(curl -s $VERSION_URL | jq -r '.downloads.server.url')
        download_with_progress "$DOWNLOAD_URL" "server.jar"
        ;;
    *)
        echo -e "${RED}Invalid choice. Installing Paper as default...${NC}"
        PAPER_BUILD=$(curl -s "https://papermc.io/api/v2/projects/paper/versions/${MC_VERSION}" | jq -r '.builds[-1]')
        download_with_progress "https://papermc.io/api/v2/projects/paper/versions/${MC_VERSION}/builds/${PAPER_BUILD}/downloads/paper-${MC_VERSION}-${PAPER_BUILD}.jar" "server.jar"
        ;;
esac

# Verify download
if [ ! -f "server.jar" ]; then
    echo -e "${RED}Error: Failed to download server.jar${NC}"
    exit 1
fi

# Check file size (minimum 1MB)
if [ $(stat -f%z "server.jar" 2>/dev/null || stat -c%s "server.jar" 2>/dev/null) -lt 1000000 ]; then
    echo -e "${RED}Error: server.jar is too small, download may have failed${NC}"
    rm server.jar
    exit 1
fi

# Create server.properties with enhanced configuration
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

# Accept EULA
echo "eula=true" > eula.txt

# Download server icon
curl -o server-icon.png "https://i.postimg.cc/rwZPYnGV/IMG-20250203-221310-1.png"

# Create plugins folder and download essential plugins
mkdir -p plugins
echo -e "${CYAN}Downloading essential plugins...${NC}"
curl -L -o plugins/EssentialsX.jar "https://github.com/EssentialsX/Essentials/releases/download/2.19.7/EssentialsX-2.19.7.jar"
curl -L -o plugins/LuckPerms.jar "https://ci.lucko.me/job/LuckPerms/1515/artifact/bukkit/loader/build/libs/LuckPerms-Bukkit-5.4.40.jar"

animate_text "Installation complete! Server is ready to start." "${GREEN}${BOLD}"
