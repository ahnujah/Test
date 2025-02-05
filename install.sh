#!/bin/bash
# install.sh

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Clear screen and show banner
clear
cat << "EOF"
 ██████╗███████╗ █████╗ ██████╗  █████╗  ██████╗████████╗██╗   ██╗██╗     
██╔════╝╚══███╔╝██╔══██╗██╔══██╗██╔══██╗██╔════╝╚══██╔══╝╚██╗ ██╔╝██║     
██║       ███╔╝ ███████║██████╔╝███████║██║        ██║    ╚████╔╝ ██║     
██║      ███╔╝  ██╔══██║██╔══██╗██╔══██║██║        ██║     ╚██╔╝  ██║     
╚██████╗███████╗██║  ██║██║  ██║██║  ██║╚██████╗   ██║      ██║   ███████╗
 ╚═════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝   ╚═╝      ╚═╝   ╚══════╝
EOF

echo -e "${CYAN}${BOLD}==========================================================================${NC}"
echo -e "${YELLOW}${BOLD}                    Welcome to Czaractyl Installation${NC}"
echo -e "${CYAN}${BOLD}==========================================================================${NC}"
echo -e "${GREEN}Please choose your Minecraft server software:${NC}\n"
echo -e "${BOLD}[1]${NC} Paper         ${CYAN}(Recommended for vanilla + plugins)${NC}"
echo -e "${BOLD}[2]${NC} Purpur        ${CYAN}(Paper fork with more features)${NC}"
echo -e "${BOLD}[3]${NC} Forge         ${CYAN}(For modded Minecraft)${NC}"
echo -e "${BOLD}[4]${NC} Fabric        ${CYAN}(Lightweight mod loader)${NC}"
echo -e "${BOLD}[5]${NC} Vanilla       ${CYAN}(Official Minecraft server)${NC}"
echo -e "${BOLD}[6]${NC} Spigot        ${CYAN}(CraftBukkit fork)${NC}"
echo -e "${BOLD}[7]${NC} Waterfall     ${CYAN}(BungeeCord fork - Proxy)${NC}"
echo -e "${BOLD}[8]${NC} Velocity      ${CYAN}(Modern Minecraft proxy)${NC}"
echo -e "${BOLD}[9]${NC} Mohist        ${CYAN}(Forge + Spigot hybrid)${NC}"
echo -e "${CYAN}${BOLD}==========================================================================${NC}"

read -p "$(echo -e ${YELLOW}"Enter your choice (1-9): "${NC})" choice

# Function to show spinner
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Function to download with progress
download_with_progress() {
    echo -e "${CYAN}Downloading server files...${NC}"
    curl -#L "$1" -o "$2"
}

case $choice in
    1)
        echo -e "${GREEN}Installing Paper...${NC}"
        download_with_progress "https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/441/downloads/paper-1.20.4-441.jar" "server.jar"
        ;;
    2)
        echo -e "${GREEN}Installing Purpur...${NC}"
        download_with_progress "https://api.purpurmc.org/v2/purpur/1.20.4/latest/download" "server.jar"
        ;;
    3)
        echo -e "${GREEN}Installing Forge...${NC}"
        echo -e "${YELLOW}Enter Minecraft version (e.g., 1.20.4):${NC}"
        read MC_VERSION
        download_with_progress "https://maven.minecraftforge.net/net/minecraftforge/forge/${MC_VERSION}-latest/forge-${MC_VERSION}-latest-installer.jar" "forge-installer.jar"
        java -jar forge-installer.jar --installServer
        rm forge-installer.jar
        mv forge-*-universal.jar server.jar
        ;;
    4)
        echo -e "${GREEN}Installing Fabric...${NC}"
        echo -e "${YELLOW}Enter Minecraft version (e.g., 1.20.4):${NC}"
        read MC_VERSION
        download_with_progress "https://meta.fabricmc.net/v2/versions/loader/${MC_VERSION}/0.15.6/1.0.0/server/jar" "server.jar"
        ;;
    5)
        echo -e "${GREEN}Installing Vanilla...${NC}"
        download_with_progress "https://piston-data.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e594d/server.jar" "server.jar"
        ;;
    6)
        echo -e "${GREEN}Installing Spigot...${NC}"
        download_with_progress "https://download.getbukkit.org/spigot/spigot-1.20.4.jar" "server.jar"
        ;;
    7)
        echo -e "${GREEN}Installing Waterfall...${NC}"
        download_with_progress "https://api.papermc.io/v2/projects/waterfall/versions/1.20/builds/543/downloads/waterfall-1.20-543.jar" "server.jar"
        ;;
    8)
        echo -e "${GREEN}Installing Velocity...${NC}"
        download_with_progress "https://api.papermc.io/v2/projects/velocity/versions/3.3.0-SNAPSHOT/builds/297/downloads/velocity-3.3.0-SNAPSHOT-297.jar" "server.jar"
        ;;
    9)
        echo -e "${GREEN}Installing Mohist...${NC}"
        download_with_progress "https://mohistmc.com/api/v2/projects/mohist/1.20.4/latest/download" "server.jar"
        ;;
    *)
        echo -e "${RED}Invalid choice. Installing Paper as default...${NC}"
        download_with_progress "https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/441/downloads/paper-1.20.4-441.jar" "server.jar"
        ;;
esac

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

# Create server icon if it doesn't exist
if [ ! -f "server-icon.png" ]; then
    curl -o server-icon.png "https://raw.githubusercontent.com/ahnujah/Test/main/server-icon.png"
fi

echo -e "${GREEN}${BOLD}Installation complete! Starting server...${NC}"
