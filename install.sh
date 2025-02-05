#!/bin/bash

# Czaractyl Installation Script
# https://github.com/ahnujah/Test

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

# Install required tools
apk add --no-cache curl jq

case $choice in
    1)
        echo "Installing Paper..."
        LATEST_VERSION=$(curl -s https://papermc.io/api/v2/projects/paper | jq -r '.versions[-1]')
        BUILD_NUMBER=$(curl -s https://papermc.io/api/v2/projects/paper/versions/${LATEST_VERSION} | jq -r '.builds[-1]')
        JAR_NAME="paper-${LATEST_VERSION}-${BUILD_NUMBER}.jar"
        DOWNLOAD_URL="https://papermc.io/api/v2/projects/paper/versions/${LATEST_VERSION}/builds/${BUILD_NUMBER}/downloads/${JAR_NAME}"
        curl -o server.jar $DOWNLOAD_URL
        ;;
    2)
        echo "Installing Forge..."
        read -p "Enter Minecraft version (e.g., 1.19.2): " MC_VERSION
        FORGE_VERSION=$(curl -s https://files.minecraftforge.net/net/minecraftforge/forge/promotions_slim.json | jq -r --arg MC_VERSION "$MC_VERSION" '.promos | to_entries[] | select(.key | startswith($MC_VERSION)) | .value' | head -n 1)
        DOWNLOAD_URL="https://maven.minecraftforge.net/net/minecraftforge/forge/${MC_VERSION}-${FORGE_VERSION}/forge-${MC_VERSION}-${FORGE_VERSION}-installer.jar"
        curl -o forge-installer.jar $DOWNLOAD_URL
        java -jar forge-installer.jar --installServer
        rm forge-installer.jar
        mv forge-*-universal.jar server.jar
        ;;
    3)
        echo "Installing Fabric..."
        read -p "Enter Minecraft version (e.g., 1.19.2): " MC_VERSION
        FABRIC_VERSION=$(curl -s https://meta.fabricmc.net/v2/versions/installer | jq -r '.[0].version')
        curl -o fabric-installer.jar https://maven.fabricmc.net/net/fabricmc/fabric-installer/${FABRIC_VERSION}/fabric-installer-${FABRIC_VERSION}.jar
        java -jar fabric-installer.jar server -mcversion $MC_VERSION -downloadMinecraft
        rm fabric-installer.jar
        mv fabric-server-launch.jar server.jar
        ;;
    4)
        echo "Installing Vanilla Minecraft..."
        MANIFEST_URL="https://launchermeta.mojang.com/mc/game/version_manifest.json"
        LATEST_VERSION=$(curl -s $MANIFEST_URL | jq -r '.latest.release')
        VERSION_URL=$(curl -s $MANIFEST_URL | jq -r --arg VERSION "$LATEST_VERSION" '.versions[] | select(.id == $VERSION) | .url')
        DOWNLOAD_URL=$(curl -s $VERSION_URL | jq -r '.downloads.server.url')
        curl -o server.jar $DOWNLOAD_URL
        ;;
    5)
        echo "Installing Spigot..."
        mkdir -p BuildTools && cd BuildTools
        curl -o BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
        java -jar BuildTools.jar --rev latest
        mv spigot-*.jar ../server.jar
        cd .. && rm -rf BuildTools
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Create server.properties with basic configuration
echo "server-port=${SERVER_PORT}" > server.properties
echo "motd=A Minecraft Server powered by Czaractyl" >> server.properties

# Accept EULA
echo "eula=true" > eula.txt

echo "Installation complete! Server jar has been downloaded as server.jar"
