#!/bin/bash
# install.sh

# Czaractyl Installation Script
clear
echo "==================================="
echo "Welcome to Czaractyl Installation"
echo "==================================="
echo "Please choose your server software:"
echo "1. Paper (Latest builds of Paper)"
echo "2. Vanilla (Official Minecraft)"
echo "==================================="

read -p "Enter your choice (1-2): " choice

case $choice in
    1)
        echo "Installing Paper..."
        # Direct download from Paper's CDN
        curl -k -o server.jar "https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/441/downloads/paper-1.20.4-441.jar"
        ;;
    2)
        echo "Installing Vanilla..."
        # Direct download from Mojang
        curl -k -o server.jar "https://piston-data.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e594d/server.jar"
        ;;
    *)
        echo "Invalid choice. Installing Paper as default..."
        curl -k -o server.jar "https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/441/downloads/paper-1.20.4-441.jar"
        ;;
esac

# Verify download
if [ ! -f "server.jar" ]; then
    echo "Error: Failed to download server.jar"
    exit 1
fi

# Check file size (minimum 1MB)
if [ $(stat -f%z "server.jar" 2>/dev/null || stat -c%s "server.jar" 2>/dev/null) -lt 1000000 ]; then
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
