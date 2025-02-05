#!/bin/bash
# install.sh

# Debug mode to see what's happening
set -x

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

case $choice in
    1)
        echo "Installing Paper..."
        # Get latest version
        PAPER_API="https://papermc.io/api/v2/projects/paper"
        VERSION=$(curl -s $PAPER_API | grep -o '"versions":\[.*\]' | grep -o '"[^"]*"' | head -1 | tr -d '"')
        echo "Latest version: $VERSION"
        
        # Get latest build
        BUILD_API="$PAPER_API/versions/$VERSION"
        BUILD=$(curl -s $BUILD_API | grep -o '"builds":\[.*\]' | grep -o '[0-9]*' | tail -1)
        echo "Latest build: $BUILD"
        
        # Download paper
        DOWNLOAD_URL="https://papermc.io/api/v2/projects/paper/versions/$VERSION/builds/$BUILD/downloads/paper-$VERSION-$BUILD.jar"
        echo "Downloading from: $DOWNLOAD_URL"
        curl -o server.jar -L "$DOWNLOAD_URL"
        ;;
    2)
        echo "Installing Vanilla (fallback for now)..."
        MANIFEST="https://launchermeta.mojang.com/mc/game/version_manifest.json"
        LATEST=$(curl -s $MANIFEST | grep -o '"release": "[^"]*"' | cut -d'"' -f4)
        VERSION_URL=$(curl -s $MANIFEST | grep -o "\"$LATEST\".*{" -A 4 | grep -o 'https://[^"]*')
        DOWNLOAD_URL=$(curl -s $VERSION_URL | grep -o '"server": {[^}]*}' | grep -o 'https://[^"]*')
        curl -o server.jar -L "$DOWNLOAD_URL"
        ;;
    *)
        echo "Installing Paper (default)..."
        # Same as option 1
        PAPER_API="https://papermc.io/api/v2/projects/paper"
        VERSION=$(curl -s $PAPER_API | grep -o '"versions":\[.*\]' | grep -o '"[^"]*"' | head -1 | tr -d '"')
        BUILD_API="$PAPER_API/versions/$VERSION"
        BUILD=$(curl -s $BUILD_API | grep -o '"builds":\[.*\]' | grep -o '[0-9]*' | tail -1)
        DOWNLOAD_URL="https://papermc.io/api/v2/projects/paper/versions/$VERSION/builds/$BUILD/downloads/paper-$VERSION-$BUILD.jar"
        curl -o server.jar -L "$DOWNLOAD_URL"
        ;;
esac

# Verify download
if [ ! -f "server.jar" ]; then
    echo "Error: Failed to download server.jar"
    exit 1
fi

# Check file size
if [ $(stat -f%z "server.jar" 2>/dev/null || stat -c%s "server.jar" 2>/dev/null) -lt 1000 ]; then
    echo "Error: server.jar is too small, download may have failed"
    rm server.jar
    exit 1
fi

# Create server.properties
echo "server-port=${SERVER_PORT:-25565}" > server.properties
echo "motd=A Minecraft Server powered by Czaractyl" >> server.properties

# Accept EULA
echo "eula=true" > eula.txt

echo "Installation complete! Server jar has been downloaded as server.jar"
