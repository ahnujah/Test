#!/bin/bash

# Czaractyl Installation Script

echo "Welcome to Czaractyl Installation"
echo "Server Type: $SERVER_TYPE"
echo "Server Version: $SERVER_VERSION"
echo "Build Number: $BUILD_NUMBER"

case $SERVER_TYPE in
    paper)
        if [ "$SERVER_VERSION" == "latest" ]; then
            SERVER_VERSION=$(curl -s https://papermc.io/api/v2/projects/paper | jq -r '.versions[-1]')
        fi
        if [ "$BUILD_NUMBER" == "latest" ]; then
            BUILD_NUMBER=$(curl -s https://papermc.io/api/v2/projects/paper/versions/${SERVER_VERSION} | jq -r '.builds[-1]')
        fi
        JAR_NAME="paper-${SERVER_VERSION}-${BUILD_NUMBER}.jar"
        DOWNLOAD_URL="https://papermc.io/api/v2/projects/paper/versions/${SERVER_VERSION}/builds/${BUILD_NUMBER}/downloads/${JAR_NAME}"
        ;;
    forge)
        # You'll need to implement Forge version fetching logic here
        DOWNLOAD_URL="https://files.minecraftforge.net/maven/net/minecraftforge/forge/${SERVER_VERSION}/forge-${SERVER_VERSION}-installer.jar"
        JAR_NAME="forge-${SERVER_VERSION}-installer.jar"
        ;;
    fabric)
        FABRIC_VERSION=$(curl -s https://meta.fabricmc.net/v2/versions/installer | jq -r '.[0].version')
        DOWNLOAD_URL="https://maven.fabricmc.net/net/fabricmc/fabric-installer/${FABRIC_VERSION}/fabric-installer-${FABRIC_VERSION}.jar"
        JAR_NAME="fabric-installer.jar"
        ;;
    sponge)
        # You'll need to implement Sponge version fetching logic here
        DOWNLOAD_URL="https://repo.spongepowered.org/maven/org/spongepowered/spongevanilla/${SERVER_VERSION}/spongevanilla-${SERVER_VERSION}.jar"
        JAR_NAME="sponge-${SERVER_VERSION}.jar"
        ;;
    vanilla)
        MANIFEST_URL="https://launchermeta.mojang.com/mc/game/version_manifest.json"
        if [ "$SERVER_VERSION" == "latest" ]; then
            SERVER_VERSION=$(curl -s $MANIFEST_URL | jq -r '.latest.release')
        fi
        VERSION_URL=$(curl -s $MANIFEST_URL | jq -r --arg VERSION "$SERVER_VERSION" '.versions[] | select(.id == $VERSION) | .url')
        DOWNLOAD_URL=$(curl -s $VERSION_URL | jq -r '.downloads.server.url')
        JAR_NAME="minecraft_server.${SERVER_VERSION}.jar"
        ;;
    *)
        echo "Invalid server type specified"
        exit 1
        ;;
esac

echo "Downloading server jar..."
curl -o server.jar $DOWNLOAD_URL

if [ "$SERVER_TYPE" == "forge" ]; then
    echo "Installing Forge server..."
    java -jar server.jar --installServer
    rm server.jar
    mv forge-*-universal.jar server.jar
elif [ "$SERVER_TYPE" == "fabric" ]; then
    echo "Installing Fabric server..."
    java -jar server.jar server -mcversion $SERVER_VERSION -downloadMinecraft
    rm server.jar
    mv fabric-server-launch.jar server.jar
fi

echo "eula=true" > eula.txt

echo "Installation complete!"
