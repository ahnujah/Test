#!/bin/bash
# install.sh

# Czaractyl Installation Script
echo "==================================="
echo "Welcome to Czaractyl Installation"
echo "==================================="
echo "Please choose your server software:"
echo "1. Paper (Latest builds of Paper)"
echo "2. Forge (Modded Minecraft)"
echo "3. Fabric (Modern mod loader)"
echo "4. Vanilla (Official Minecraft)"
echo "5. Spigot (CraftBukkit fork)"
echo "==================================="

read -p "Enter your choice (1-5): " choice

# Function to get latest Paper version and build
get_paper_latest() {
    local version=$(curl -s https://papermc.io/api/v2/projects/paper | grep -o '"versions":\["[^"]*"' | cut -d'"' -f4)
    local build=$(curl -s "https://papermc.io/api/v2/projects/paper/versions/$version/builds" | grep -o '"builds":\[[0-9]*' | grep -o '[0-9]*')
    echo "$version $build"
}

case $choice in
    1)
        echo "Installing Paper..."
        read paper_info < <(get_paper_latest)
        version=${paper_info% *}
        build=${paper_info#* }
        echo "Latest version: $version, build: $build"
        download_url="https://papermc.io/api/v2/projects/paper/versions/${version}/builds/${build}/downloads/paper-${version}-${build}.jar"
        curl -o server.jar -L "$download_url"
        ;;
    2)
        echo "Installing Forge..."
        read -p "Enter Minecraft version (e.g., 1.19.2): " MC_VERSION
        FORGE_URL="https://files.minecraftforge.net/maven/net/minecraftforge/forge/${MC_VERSION}-latest/forge-${MC_VERSION}-latest-installer.jar"
        curl -o forge-installer.jar -L "$FORGE_URL"
        java -jar forge-installer.jar --installServer
        rm forge-installer.jar
        mv forge-*-universal.jar server.jar
        ;;
    3)
        echo "Installing Fabric..."
        read -p "Enter Minecraft version (e.g., 1.19.2): " MC_VERSION
        curl -o fabric-installer.jar -L "https://maven.fabricmc.net/net/fabricmc/fabric-installer/0.11.1/fabric-installer-0.11.1.jar"
        java -jar fabric-installer.jar server -mcversion "$MC_VERSION" -downloadMinecraft
        rm fabric-installer.jar
        mv fabric-server-launch.jar server.jar
        ;;
    4)
        echo "Installing Vanilla..."
        MANIFEST_URL="https://launchermeta.mojang.com/mc/game/version_manifest.json"
        latest_version=$(curl -s "$MANIFEST_URL" | grep -o '"release": "[^"]*"' | cut -d'"' -f4)
        version_url=$(curl -s "$MANIFEST_URL" | grep -o "\"${latest_version}\".*{" -A 4 | grep -o 'https://[^"]*')
        download_url=$(curl -s "$version_url" | grep -o '"server": {[^}]*}' | grep -o 'https://[^"]*')
        curl -o server.jar -L "$download_url"
        ;;
    5)
        echo "Installing Spigot..."
        mkdir -p BuildTools && cd BuildTools
        curl -o BuildTools.jar -L "https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar"
        java -jar BuildTools.jar --rev latest
        mv spigot-*.jar ../server.jar
        cd .. && rm -rf BuildTools
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Verify server.jar was downloaded successfully
if [ ! -f "server.jar" ]; then
    echo "Error: Failed to download server.jar"
    exit 1
fi

# Create server.properties with basic configuration
echo "server-port=${SERVER_PORT:-25565}" > server.properties
echo "motd=A Minecraft Server powered by Czaractyl" >> server.properties

# Accept EULA
echo "eula=true" > eula.txt

echo "Installation complete! Server jar has been downloaded as server.jar"
