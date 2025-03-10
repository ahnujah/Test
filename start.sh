#!/bin/bash

# ███████████████████████████████████████████████████████████████████████████████
# █                                                                             █
# █                        𝗔𝗨𝗥𝗔𝗡𝗢𝗗𝗘𝗦 𝗨𝗟𝗧𝗜𝗠𝗔𝗧𝗘 𝗦𝗘𝗥𝗩𝗘𝗥 𝗠𝗔𝗡𝗔𝗚𝗘𝗥                        █
# █                                                                             █
# █                      Premium Minecraft Server Solution                      █
# █                                                                             █
# ███████████████████████████████████████████████████████████████████████████████

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ CONFIGURATION                                                              ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Version information
VERSION="3.5.1"
CODENAME="Crystal Phoenix"

# Default settings (can be overridden by environment variables)
DEFAULT_MEMORY="1G"
DEFAULT_PORT="25565"
DEFAULT_MC_VERSION="1.20.4"

# Enhanced color palette
RESET="\033[0m"
BLACK="\033[0;30m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"
WHITE="\033[0;37m"
BOLD_BLACK="\033[1;30m"
BOLD_RED="\033[1;31m"
BOLD_GREEN="\033[1;32m"
BOLD_YELLOW="\033[1;33m"
BOLD_BLUE="\033[1;34m"
BOLD_PURPLE="\033[1;35m"
BOLD_CYAN="\033[1;36m"
BOLD_WHITE="\033[1;37m"
BG_BLACK="\033[40m"
BG_RED="\033[41m"
BG_GREEN="\033[42m"
BG_YELLOW="\033[43m"
BG_BLUE="\033[44m"
BG_PURPLE="\033[45m"
BG_CYAN="\033[46m"
BG_WHITE="\033[47m"
UNDERLINE="\033[4m"
BLINK="\033[5m"
REVERSE="\033[7m"
HIDDEN="\033[8m"

# Unicode symbols
CHECK_MARK="✓"
CROSS_MARK="✗"
ARROW="➤"
STAR="★"
DIAMOND="♦"
HEART="♥"
LIGHTNING="⚡"
WRENCH="🔧"
GEAR="⚙️"
ROCKET="🚀"
SPARKLES="✨"
FIRE="🔥"
GLOBE="🌐"
SHIELD="🛡️"
KEY="🔑"
PLUG="🔌"
MAGIC="✨"
CROWN="👑"

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ ERROR HANDLING                                                             ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Set up error handling
set -o pipefail

# Error handling function
handle_error() {
    local exit_code=$1
    local error_line=$2
    local error_command=$3
    
    echo -e "\n${BOLD_RED}ERROR: Command '${error_command}' failed with exit code ${exit_code} at line ${error_line}${RESET}"
    echo -e "${BOLD_YELLOW}The script encountered an error. Please check the output above for details.${RESET}"
    
    # Clean up any temporary files or processes
    cleanup
    
    # Exit with error code
    exit $exit_code
}

# Set up trap for errors
trap 'handle_error $? $LINENO "$BASH_COMMAND"' ERR

# Cleanup function
cleanup() {
    # Kill any background processes
    if [ -f .spinner.pid ]; then
        kill $(cat .spinner.pid) > /dev/null 2>&1 || true
        rm .spinner.pid
    fi
    
    # Remove temporary files
    rm -f .temp_* 2>/dev/null || true
}

# Set up trap for script exit
trap cleanup EXIT

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ UTILITY FUNCTIONS                                                          ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Function to print centered text with optional color
print_centered() {
    local text="$1"
    local color="${2:-$RESET}"
    local width=$(tput cols 2>/dev/null || echo 80)
    local padding=$(( (width - ${#text}) / 2 ))
    
    printf "%${padding}s" ""
    echo -e "${color}${text}${RESET}"
}

# Function to print a horizontal line
print_line() {
    local character="${1:-═}"
    local color="${2:-$BOLD_CYAN}"
    local width=$(tput cols 2>/dev/null || echo 80)
    
    echo -ne "$color"
    for ((i=0; i<width; i++)); do
        echo -n "$character"
    done
    echo -e "$RESET"
}

# Function to print a section header
print_header() {
    local title="$1"
    local color="${2:-$BOLD_CYAN}"
    local icon="${3:-}"
    
    echo
    print_line "═" "$color"
    if [ -n "$icon" ]; then
        print_centered "$icon $title $icon" "$color"
    else
        print_centered "$title" "$color"
    fi
    print_line "═" "$color"
    echo
}

# Simple text output function
simple_text() {
    local text="$1"
    local color="${2:-$BOLD_CYAN}"
    echo -e "${color}${text}${RESET}"
}

# Function to display a simple progress bar
simple_progress() {
    local duration=$1
    local message="$2"
    local color="${3:-$BOLD_GREEN}"
    local width=50
    
    echo -ne "$message ["
    for ((i=0; i<width; i++)); do
        echo -ne " "
    done
    echo -ne "] 0%\r"
    
    for ((i=0; i<=width; i++)); do
        local percent=$((i*100/width))
        
        echo -ne "\r$message ["
        for ((j=0; j<i; j++)); do
            echo -ne "${color}█${RESET}"
        done
        for ((j=i; j<width; j++)); do
            echo -ne " "
        done
        echo -ne "] ${percent}%"
        
        sleep $(echo "scale=3; $duration/$width" | bc 2>/dev/null || echo 0.02)
    done
    echo
}

# Function to display a spinner animation
spinner() {
    local message="$1"
    local delay=0.1
    local spinstr='|/-\'
    
    while true; do
        for ((i=0; i<${#spinstr}; i++)); do
            echo -ne "\r$message [${spinstr:$i:1}]"
            sleep $delay
        done
    done
}

# Function to start spinner in background
start_spinner() {
    local message="$1"
    spinner "$message" &
    echo $! > .spinner.pid
}

# Function to stop spinner
stop_spinner() {
    if [ -f .spinner.pid ]; then
        kill $(cat .spinner.pid) > /dev/null 2>&1 || true
        rm .spinner.pid
    fi
    echo -e "\r\033[K"
}

# Function to display a fancy box with text
fancy_box() {
    local text="$1"
    local color="${2:-$BOLD_CYAN}"
    local width=$(tput cols 2>/dev/null || echo 80)
    local text_width=${#text}
    local padding=$(( (width - text_width - 4) / 2 ))
    
    echo -ne "$color"
    printf "%${width}s" | tr " " "═"
    echo -e "$RESET"
    
    echo -ne "$color║$RESET"
    printf "%${padding}s" ""
    echo -ne "$text"
    printf "%$(( width - padding - text_width - 2 ))s" ""
    echo -e "$color║$RESET"
    
    echo -ne "$color"
    printf "%${width}s" | tr " " "═"
    echo -e "$RESET"
}

# Function to display a menu with options
display_menu() {
    local title="$1"
    local icon="${2:-}"
    shift
    if [ -n "$icon" ]; then
        shift
    fi
    local options=("$@")
    
    if [ -n "$icon" ]; then
        print_header "$title" "$BOLD_CYAN" "$icon"
    else
        print_header "$title"
    fi
    
    for ((i=0; i<${#options[@]}; i++)); do
        local option_num=$((i+1))
        echo -e " ${BOLD_WHITE}${option_num})${RESET} ${options[$i]}"
    done
    
    echo
    echo -ne " ${BOLD_YELLOW}${ARROW} ${RESET}Enter your choice (1-${#options[@]}): "
}

# Function to get user input with validation
get_input() {
    local prompt="$1"
    local default="$2"
    local validation="$3"
    local result
    
    while true; do
        echo -ne "${BOLD_YELLOW}${ARROW} ${RESET}${prompt}"
        if [ -n "$default" ]; then
            echo -ne " [${BOLD_GREEN}${default}${RESET}]: "
        else
            echo -ne ": "
        fi
        
        read -r result
        
        # Use default if input is empty
        if [ -z "$result" ] && [ -n "$default" ]; then
            result="$default"
        fi
        
        # Validate input if validation function is provided
        if [ -n "$validation" ] && ! $validation "$result"; then
            echo -e "${BOLD_RED}${CROSS_MARK} Invalid input. Please try again.${RESET}"
            continue
        fi
        
        break
    done
    
    echo "$result"
}

# Function to get yes/no input
get_yes_no() {
    local prompt="$1"
    local default="${2:-y}"
    local result
    
    while true; do
        echo -ne "${BOLD_YELLOW}${ARROW} ${RESET}${prompt} (${default^^}/${default:0:1==y?n:y}): "
        read -r result
        
        # Use default if input is empty
        if [ -z "$result" ]; then
            result="$default"
        fi
        
        # Convert to lowercase
        result=$(echo "$result" | tr '[:upper:]' '[:lower:]')
        
        # Validate input
        if [[ "$result" == "y" || "$result" == "yes" || "$result" == "n" || "$result" == "no" ]]; then
            break
        else
            echo -e "${BOLD_RED}${CROSS_MARK} Invalid input. Please enter Y/N.${RESET}"
        fi
    done
    
    [[ "$result" == "y" || "$result" == "yes" ]]
}

# Function to validate numeric input
validate_numeric() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

# Function to validate version input
validate_version() {
    [[ "$1" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]] || [ "$1" == "latest" ]
}

# Function to validate memory input
validate_memory() {
    [[ "$1" =~ ^[0-9]+[MG]$ ]]
}

# Function to validate port input
validate_port() {
    [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -ge 1 ] && [ "$1" -le 65535 ]
}

# Function to log messages
log_message() {
    local level="$1"
    local message="$2"
    local color="$RESET"
    local prefix=""
    
    case "$level" in
        "info")
            color="$BOLD_BLUE"
            prefix="${BOLD_BLUE}[INFO]${RESET}"
            ;;
        "success")
            color="$BOLD_GREEN"
            prefix="${BOLD_GREEN}[SUCCESS]${RESET}"
            ;;
        "warning")
            color="$BOLD_YELLOW"
            prefix="${BOLD_YELLOW}[WARNING]${RESET}"
            ;;
        "error")
            color="$BOLD_RED"
            prefix="${BOLD_RED}[ERROR]${RESET}"
            ;;
        *)
            prefix="${BOLD_WHITE}[LOG]${RESET}"
            ;;
    esac
    
    echo -e "${prefix} ${message}"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ CORE FUNCTIONS                                                             ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Function to display the banner
show_banner() {
    clear
    echo -e "${BOLD_CYAN}"
    cat << "EOF"
    █████╗ ██╗   ██╗██████╗  █████╗ ███╗   ██╗ ██████╗ ██████╗ ███████╗███████╗
   ██╔══██╗██║   ██║██╔══██╗██╔══██╗████╗  ██║██╔═══██╗██╔══██╗██╔════╝██╔════╝
   ███████║██║   ██║██████╔╝███████║██╔██╗ ██║██║   ██║██║  ██║█████╗  ███████╗
   ██╔══██║██║   ██║██╔══██╗██╔══██║██║╚██╗██║██║   ██║██║  ██║██╔══╝  ╚════██║
   ██║  ██║╚██████╔╝██║  ██║██║  ██║██║ ╚████║╚██████╔╝██████╔╝███████╗███████║
   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝╚══════╝
EOF
    echo -e "${RESET}"
    
    # Use simple text instead of gradient_text
    simple_text "✧ ULTIMATE MINECRAFT SERVER MANAGER ✧" "$BOLD_YELLOW"
    print_centered "Version ${VERSION} - ${CODENAME}" "$BOLD_WHITE"
    print_line "═" "$BOLD_CYAN"
    echo
}

# Function to check and install dependencies
check_dependencies() {
    print_header "System Preparation" "$BOLD_CYAN" "$WRENCH"
    
    local dependencies=("curl" "wget" "unzip" "java" "screen")
    local missing_deps=()
    
    echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Checking required dependencies..."
    
    for dep in "${dependencies[@]}"; do
        echo -ne "  ${BOLD_WHITE}${dep}${RESET}: "
        if command_exists "$dep"; then
            echo -e "${BOLD_GREEN}${CHECK_MARK} Installed${RESET}"
        else
            echo -e "${BOLD_RED}${CROSS_MARK} Missing${RESET}"
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo
        echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Missing dependencies: ${BOLD_WHITE}${missing_deps[*]}${RESET}"
        
        # Try to detect package manager
        if command_exists apt-get; then
            echo -e "${BOLD_YELLOW}${ARROW} ${RESET}To install missing dependencies, run:"
            echo -e "  ${BOLD_WHITE}sudo apt-get update && sudo apt-get install -y ${missing_deps[*]}${RESET}"
        elif command_exists yum; then
            echo -e "${BOLD_YELLOW}${ARROW} ${RESET}To install missing dependencies, run:"
            echo -e "  ${BOLD_WHITE}sudo yum install -y ${missing_deps[*]}${RESET}"
        elif command_exists dnf; then
            echo -e "${BOLD_YELLOW}${ARROW} ${RESET}To install missing dependencies, run:"
            echo -e "  ${BOLD_WHITE}sudo dnf install -y ${missing_deps[*]}${RESET}"
        elif command_exists pacman; then
            echo -e "${BOLD_YELLOW}${ARROW} ${RESET}To install missing dependencies, run:"
            echo -e "  ${BOLD_WHITE}sudo pacman -Sy ${missing_deps[*]}${RESET}"
        fi
        
        echo -e "${BOLD_YELLOW}${ARROW} ${RESET}The script will continue but some features may not work correctly."
        echo
        sleep 2
    else
        echo
        echo -e "${BOLD_GREEN}${CHECK_MARK} All dependencies are already installed!${RESET}"
    fi
}

# Function to detect Java version and set appropriate flags
setup_java() {
    print_header "Java Configuration" "$BOLD_CYAN" "$GEAR"
    
    # Get Java version
    if command_exists java; then
        local java_version_output
        java_version_output=$(java -version 2>&1)
        JAVA_VERSION=$(echo "$java_version_output" | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
        local java_vendor=$(echo "$java_version_output" | grep -o "OpenJDK\|HotSpot\|Temurin\|GraalVM\|Zulu" | head -1)
        
        echo -e "${BOLD_GREEN}${CHECK_MARK} Java detected:${RESET}"
        echo -e "  ${BOLD_WHITE}Version:${RESET} Java ${JAVA_VERSION}"
        if [ -n "$java_vendor" ]; then
            echo -e "  ${BOLD_WHITE}Vendor:${RESET} $java_vendor"
        fi
    else
        echo -e "${BOLD_RED}${CROSS_MARK} Java not found. Please install Java 8 or higher.${RESET}"
        echo -e "${BOLD_YELLOW}${ARROW} ${RESET}The script will continue, but server startup will fail without Java."
        JAVA_VERSION=0
    fi
    
    # Set memory allocation
    if [ -n "$MEMORY" ]; then
        echo -e "  ${BOLD_WHITE}Memory:${RESET} Using configured value: ${BOLD_GREEN}${MEMORY}${RESET}"
    else
        if command_exists free; then
            TOTAL_MEMORY=$(free -m | awk '/^Mem:/{print $2}')
            
            if [ "$TOTAL_MEMORY" -gt 8000 ]; then
                MEMORY="4G"
            elif [ "$TOTAL_MEMORY" -gt 4000 ]; then
                MEMORY="2G"
            elif [ "$TOTAL_MEMORY" -gt 2000 ]; then
                MEMORY="1G"
            else
                MEMORY="512M"
            fi
            
            echo -e "  ${BOLD_WHITE}Memory:${RESET} Auto-configured: ${BOLD_GREEN}${MEMORY}${RESET} (based on system RAM: ${TOTAL_MEMORY}MB)"
        else
            MEMORY="1G"
            echo -e "  ${BOLD_WHITE}Memory:${RESET} Default: ${BOLD_GREEN}${MEMORY}${RESET} (free command not available)"
        fi
    fi
    
    # Aikar's optimized JVM flags
    echo -e "  ${BOLD_WHITE}Optimization:${RESET} Using Aikar's optimized JVM flags"
    
    JAVA_FLAGS=(
        "-XX:+UseG1GC"
        "-XX:+ParallelRefProcEnabled"
        "-XX:MaxGCPauseMillis=200"
        "-XX:+UnlockExperimentalVMOptions"
        "-XX:+DisableExplicitGC"
        "-XX:+AlwaysPreTouch"
        "-XX:G1NewSizePercent=30"
        "-XX:G1MaxNewSizePercent=40"
        "-XX:G1HeapRegionSize=8M"
        "-XX:G1ReservePercent=20"
        "-XX:G1HeapWastePercent=5"
        "-XX:G1MixedGCCountTarget=4"
        "-XX:InitiatingHeapOccupancyPercent=15"
        "-XX:G1MixedGCLiveThresholdPercent=90"
        "-XX:G1RSetUpdatingPauseTimePercent=5"
        "-XX:SurvivorRatio=32"
        "-XX:+PerfDisableSharedMem"
        "-XX:MaxTenuringThreshold=1"
        "-Dusing.aikars.flags=https://mcflags.emc.gs"
        "-Daikars.new.flags=true"
    )
    
    # Add Java-version specific flags
    if [ "$JAVA_VERSION" -ge 17 ]; then
        echo -e "  ${BOLD_WHITE}Java 17+:${RESET} Adding modern Java optimizations"
        JAVA_FLAGS+=(
            "--add-modules=jdk.incubator.vector"
            "-XX:+UnlockDiagnosticVMOptions"
            "-XX:+DisableAttachMechanism"
        )
    fi
}

# Function to get the latest plugin version for a specific Minecraft version
get_plugin_version() {
    local plugin_name="$1"
    local mc_version="$2"
    local default_version="$3"
    
    case "$plugin_name" in
        "viaversion")
            # ViaVersion is usually compatible across versions
            echo "4.9.2"
            ;;
        "viabackwards")
            # ViaBackwards is usually compatible across versions
            echo "4.8.1"
            ;;
        "essentialsx")
            # EssentialsX versions based on Minecraft version
            case "$mc_version" in
                "1.21"*) echo "2.20.1" ;;
                "1.20"*) echo "2.20.1" ;;
                "1.19"*) echo "2.19.7" ;;
                "1.18"*) echo "2.19.0" ;;
                "1.17"*) echo "2.19.0" ;;
                "1.16"*) echo "2.18.2" ;;
                *) echo "2.20.1" ;;
            esac
            ;;
        "luckperms")
            # LuckPerms versions based on Minecraft version
            echo "5.4.102"
            ;;
        "vault")
            # Vault is usually compatible across versions
            echo "1.7.3"
            ;;
        "worldedit")
            # WorldEdit versions based on Minecraft version
            case "$mc_version" in
                "1.21"*) echo "7.2.15" ;;
                "1.20"*) echo "7.2.15" ;;
                "1.19"*) echo "7.2.15" ;;
                "1.18"*) echo "7.2.12" ;;
                "1.17"*) echo "7.2.10" ;;
                "1.16"*) echo "7.2.8" ;;
                *) echo "7.2.15" ;;
            esac
            ;;
        "chunky")
            # Chunky versions based on Minecraft version
            case "$mc_version" in
                "1.21"*) echo "1.4.28" ;;
                "1.20"*) echo "1.4.28" ;;
                "1.19"*) echo "1.3.92" ;;
                "1.18"*) echo "1.3.38" ;;
                "1.17"*) echo "1.2.164" ;;
                "1.16"*) echo "1.2.164" ;;
                *) echo "1.4.28" ;;
            esac
            ;;
        *)
            # Default to provided default version
            echo "$default_version"
            ;;
    esac
}

# Function to get plugin download URL
get_plugin_url() {
    local plugin_name="$1"
    local plugin_version="$2"
    
    case "$plugin_name" in
        "viaversion")
            echo "https://github.com/ViaVersion/ViaVersion/releases/download/$plugin_version/ViaVersion-$plugin_version.jar"
            ;;
        "viabackwards")
            echo "https://github.com/ViaVersion/ViaBackwards/releases/download/$plugin_version/ViaBackwards-$plugin_version.jar"
            ;;
        "essentialsx")
            echo "https://github.com/EssentialsX/Essentials/releases/download/$plugin_version/EssentialsX-$plugin_version.jar"
            ;;
        "luckperms")
            echo "https://download.luckperms.net/1515/bukkit/loader/LuckPerms-Bukkit-$plugin_version.jar"
            ;;
        "vault")
            echo "https://github.com/MilkBowl/Vault/releases/download/$plugin_version/Vault.jar"
            ;;
        "worldedit")
            echo "https://dev.bukkit.org/projects/worldedit/files/latest"
            ;;
        "chunky")
            echo "https://cdn.modrinth.com/data/fALzjamp/versions/ytBhnGfO/Chunky-Bukkit-$plugin_version.jar"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Function to download with retry
download_with_retry() {
    local url="$1"
    local output_file="$2"
    local max_retries=3
    local retry_count=0
    local timeout=30
    
    while [ $retry_count -lt $max_retries ]; do
        if wget --timeout=$timeout --tries=3 --quiet --show-progress --progress=bar:force -O "$output_file" "$url"; then
            return 0
        fi
        
        retry_count=$((retry_count + 1))
        if [ $retry_count -lt $max_retries ]; then
            echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Download failed. Retrying ($retry_count/$max_retries)..."
            sleep 2
        else
            echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to download after $max_retries attempts."
            return 1
        fi
    done
    
    return 1
}

# Function to download and install server software
install_server() {
    local server_type=$1
    local mc_version=$2
    
    print_header "Installing ${server_type^} Server" "$BOLD_CYAN" "$ROCKET"
    
    echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Preparing to install ${BOLD_CYAN}${server_type^}${RESET} server (Minecraft ${BOLD_CYAN}${mc_version}${RESET})..."
    
    # Save the Minecraft version for plugin compatibility
    echo "$mc_version" > .mc-version
    
    # Create temporary directory for downloads
    local temp_dir=".aura_temp"
    mkdir -p "$temp_dir"
    
    case $server_type in
        "paper")
            if [ "$mc_version" == "latest" ]; then
                mc_version="$DEFAULT_MC_VERSION"
                echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Using default version: ${BOLD_CYAN}${mc_version}${RESET}"
            fi
            
            echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Fetching latest Paper build for Minecraft ${BOLD_CYAN}${mc_version}${RESET}..."
            
            # Direct download URL for Paper (fallback if API fails)
            local fallback_url="https://api.papermc.io/v2/projects/paper/versions/$mc_version/builds/latest/downloads/paper-$mc_version-latest.jar"
            
            # Try to get latest build number
            echo -ne "${BOLD_YELLOW}${ARROW} ${RESET}Fetching build information... "
            local build_info
            if ! build_info=$(curl -s --connect-timeout 10 --max-time 15 "https://api.papermc.io/v2/projects/paper/versions/$mc_version"); then
                echo -e "${BOLD_RED}${CROSS_MARK}${RESET}"
                echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Failed to fetch build information. Using fallback URL."
                
                echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Downloading Paper server jar..."
                if ! download_with_retry "$fallback_url" "server.jar"; then
                    echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to download server jar. Please check your internet connection."
                    rm -rf "$temp_dir"
                    return 1
                fi
            else
                echo -e "${BOLD_GREEN}${CHECK_MARK}${RESET}"
                
                # Extract latest build number
                local latest_build
                if ! latest_build=$(echo "$build_info" | grep -o '"builds":\[[0-9,]*\]' | grep -o '[0-9]*' | tail -1); then
                    echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Failed to parse build information. Using fallback URL."
                    
                    echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Downloading Paper server jar..."
                    if ! download_with_retry "$fallback_url" "server.jar"; then
                        echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to download server jar. Please check your internet connection."
                        rm -rf "$temp_dir"
                        return 1
                    fi
                else
                    echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Found build: ${BOLD_CYAN}#${latest_build}${RESET}"
                    
                    local download_url="https://api.papermc.io/v2/projects/paper/versions/$mc_version/builds/$latest_build/downloads/paper-$mc_version-$latest_build.jar"
                    
                    echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Downloading Paper server jar..."
                    if ! download_with_retry "$download_url" "server.jar"; then
                        echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to download server jar. Trying fallback URL..."
                        
                        if ! download_with_retry "$fallback_url" "server.jar"; then
                            echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to download server jar. Please check your internet connection."
                            rm -rf "$temp_dir"
                            return 1
                        fi
                    fi
                fi
            fi
            
            echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Paper server jar downloaded successfully!"
            echo "paper" > .server-type
            ;;
            
        "forge")
            if [ "$mc_version" == "latest" ]; then
                mc_version="$DEFAULT_MC_VERSION"
                echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Using default version: ${BOLD_CYAN}${mc_version}${RESET}"
            fi
            
            # Get latest Forge version for the specified Minecraft version
            local forge_version
            case "$mc_version" in
                "1.21.4") forge_version="49.0.14" ;;
                "1.20.4") forge_version="49.0.14" ;;
                "1.19.4") forge_version="45.1.0" ;;
                "1.18.2") forge_version="40.2.0" ;;
                "1.17.1") forge_version="37.1.1" ;;
                "1.16.5") forge_version="36.2.39" ;;
                *) forge_version="49.0.14" ;;
            esac
            
            echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Downloading Forge installer for Minecraft ${BOLD_CYAN}${mc_version}${RESET} (Forge ${BOLD_CYAN}${forge_version}${RESET})..."
            
            local download_url="https://maven.minecraftforge.net/net/minecraftforge/forge/$mc_version-$forge_version/forge-$mc_version-$forge_version-installer.jar"
            local installer_jar="$temp_dir/forge-installer.jar"
            
            if ! download_with_retry "$download_url" "$installer_jar"; then
                echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to download Forge installer. Please check your internet connection."
                rm -rf "$temp_dir"
                return 1
            fi
            
            echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Installing Forge server (this may take a while)..."
            start_spinner "Installing Forge server"
            if ! java -jar "$installer_jar" --installServer > /dev/null 2>&1; then
                stop_spinner
                echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to install Forge server. Please check Java installation."
                rm -rf "$temp_dir"
                return 1
            fi
            stop_spinner
            
            # Find the forge jar
            local forge_jar
            forge_jar=$(find . -name "forge-$mc_version-$forge_version*.jar" | grep -v installer | head -1)
            if [ -z "$forge_jar" ]; then
                forge_jar=$(find . -name "forge-*.jar" | grep -v installer | head -1)
            fi
            
            if [ -z "$forge_jar" ]; then
                echo -e "${BOLD_RED}${CROSS_MARK} Failed to find Forge server jar${RESET}"
                rm -rf "$temp_dir"
                return 1
            fi
            
            echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Forge server installed: ${BOLD_CYAN}${forge_jar}${RESET}"
            echo "forge" > .server-type
            echo "$forge_jar" > .forge-jar
            ;;
            
        "fabric")
            if [ "$mc_version" == "latest" ]; then
                mc_version="$DEFAULT_MC_VERSION"
                echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Using default version: ${BOLD_CYAN}${mc_version}${RESET}"
            fi
            
            echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Downloading Fabric installer..."
            
            # Download Fabric installer
            local fabric_version="0.15.7"
            local installer_jar="$temp_dir/fabric-installer.jar"
            local download_url="https://maven.fabricmc.net/net/fabricmc/fabric-installer/$fabric_version/fabric-installer-$fabric_version.jar"
            
            if ! download_with_retry "$download_url" "$installer_jar"; then
                echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to download Fabric installer. Please check your internet connection."
                rm -rf "$temp_dir"
                return 1
            fi
            
            echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Installing Fabric server for Minecraft ${BOLD_CYAN}${mc_version}${RESET}..."
            start_spinner "Installing Fabric server"
            if ! java -jar "$installer_jar" server -mcversion "$mc_version" -downloadMinecraft > /dev/null 2>&1; then
                stop_spinner
                echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to install Fabric server. Please check Java installation."
                rm -rf "$temp_dir"
                return 1
            fi
            stop_spinner
            
            if [ -f "fabric-server-launch.jar" ]; then
                echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Fabric server installed successfully!"
            else
                echo -e "${BOLD_RED}${CROSS_MARK} Failed to install Fabric server${RESET}"
                rm -rf "$temp_dir"
                return 1
            fi
            
            echo "fabric" > .server-type
            ;;
            
        "purpur")
            if [ "$mc_version" == "latest" ]; then
                mc_version="$DEFAULT_MC_VERSION"
                echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Using default version: ${BOLD_CYAN}${mc_version}${RESET}"
            fi
            
            echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Downloading Purpur server for Minecraft ${BOLD_CYAN}${mc_version}${RESET}..."
            
            local download_url="https://api.purpurmc.org/v2/purpur/$mc_version/latest/download"
            
            if ! download_with_retry "$download_url" "server.jar"; then
                echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to download Purpur server jar. Please check your internet connection."
                rm -rf "$temp_dir"
                return 1
            fi
            
            echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Purpur server downloaded successfully!"
            echo "purpur" > .server-type
            ;;
            
        "spigot")
            if [ "$mc_version" == "latest" ]; then
                mc_version="$DEFAULT_MC_VERSION"
                echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Using default version: ${BOLD_CYAN}${mc_version}${RESET}"
            fi
            
            echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Downloading BuildTools for Minecraft ${BOLD_CYAN}${mc_version}${RESET}..."
            
            # Download BuildTools
            local buildtools_jar="$temp_dir/BuildTools.jar"
            local download_url="https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar"
            
            if ! download_with_retry "$download_url" "$buildtools_jar"; then
                echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to download BuildTools. Please check your internet connection."
                rm -rf "$temp_dir"
                return 1
            fi
            
            echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Building Spigot server (this may take several minutes)..."
            start_spinner "Building Spigot (this will take a while)"
            if ! java -jar "$buildtools_jar" --rev "$mc_version" > /dev/null 2>&1; then
                stop_spinner
                echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to build Spigot server. Please check Java installation."
                rm -rf "$temp_dir"
                return 1
            fi
            stop_spinner
            
            # Move the built jar to server.jar
            if [ -f "spigot-$mc_version.jar" ]; then
                mv "spigot-$mc_version.jar" "server.jar"
                echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Spigot server built successfully!"
            else
                echo -e "${BOLD_RED}${CROSS_MARK} Failed to build Spigot server jar${RESET}"
                rm -rf "$temp_dir"
                return 1
            fi
            
            echo "spigot" > .server-type
            ;;
            
        "vanilla")
            if [ "$mc_version" == "latest" ]; then
                mc_version="$DEFAULT_MC_VERSION"
                echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Using default version: ${BOLD_CYAN}${mc_version}${RESET}"
            fi
            
            echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Downloading Vanilla server for Minecraft ${BOLD_CYAN}${mc_version}${RESET}..."
            
            # Vanilla download URLs by version
            local download_url
            case "$mc_version" in
                "1.21.4") download_url="https://piston-data.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e594d/server.jar" ;;
                "1.20.4") download_url="https://piston-data.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e594d/server.jar" ;;
                "1.19.4") download_url="https://piston-data.mojang.com/v1/objects/8f3112a1049751cc472ec13e397eade5336ca7ae/server.jar" ;;
                "1.18.2") download_url="https://piston-data.mojang.com/v1/objects/c8f83c5655308435b3dcf03c06d9fe8740a77469/server.jar" ;;
                "1.17.1") download_url="https://piston-data.mojang.com/v1/objects/a16d67e5807f57fc4e550299cf20226194497dc2/server.jar" ;;
                "1.16.5") download_url="https://piston-data.mojang.com/v1/objects/1b557e7b033b583cd9f66746b7a9ab1ec1673ced/server.jar" ;;
                *) download_url="https://piston-data.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e594d/server.jar" ;;
            esac
            
            if ! download_with_retry "$download_url" "server.jar"; then
                echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to download Vanilla server jar. Please check your internet connection."
                rm -rf "$temp_dir"
                return 1
            fi
            
            echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Vanilla server downloaded successfully!"
            echo "vanilla" > .server-type
            ;;
            
        "bungeecord")
            echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Downloading latest BungeeCord server..."
            
            local download_url="https://ci.md-5.net/job/BungeeCord/lastSuccessfulBuild/artifact/bootstrap/target/BungeeCord.jar"
            
            if ! download_with_retry "$download_url" "server.jar"; then
                echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to download BungeeCord server jar. Please check your internet connection."
                rm -rf "$temp_dir"
                return 1
            fi
            
            echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}BungeeCord server downloaded successfully!"
            echo "bungeecord" > .server-type
            ;;
            
        "velocity")
            echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Downloading latest Velocity server..."
            
            local download_url="https://api.papermc.io/v2/projects/velocity/versions/3.2.0-SNAPSHOT/builds/263/downloads/velocity-3.2.0-SNAPSHOT-263.jar"
            
            if ! download_with_retry "$download_url" "server.jar"; then
                echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to download Velocity server jar. Please check your internet connection."
                rm -rf "$temp_dir"
                return 1
            fi
            
            echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Velocity server downloaded successfully!"
            echo "velocity" > .server-type
            ;;
            
        *)
            echo -e "${BOLD_RED}${CROSS_MARK} Unsupported server type: $server_type${RESET}"
            rm -rf "$temp_dir"
            return 1
            ;;
    esac
    
    # Clean up temporary directory
    rm -rf "$temp_dir"
    
    fancy_box "${SPARKLES} Server software installed successfully! ${SPARKLES}" "$BOLD_GREEN"
    return 0
}

# Function to install plugins
install_plugins() {
    local server_type
    server_type=$(cat .server-type 2>/dev/null || echo "unknown")
    local mc_version
    mc_version=$(cat .mc-version 2>/dev/null || echo "$DEFAULT_MC_VERSION")
    
    print_header "Plugin Installation" "$BOLD_CYAN" "$PLUG"
    
    # Skip plugin installation for certain server types
    if [[ "$server_type" == "vanilla" || "$server_type" == "forge" || "$server_type" == "bungeecord" || "$server_type" == "velocity" ]]; then
        echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Skipping plugin installation for ${BOLD_CYAN}${server_type^}${RESET} server"
        return 0
    fi
    
    echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Installing essential plugins for ${BOLD_CYAN}${server_type^}${RESET} server (Minecraft ${BOLD_CYAN}${mc_version}${RESET})..."
    mkdir -p plugins
    
    # Define plugins to install based on server type
    declare -A plugins
    declare -A plugin_versions
    
    # Common plugins for all supported server types
    plugins["essentialsx"]="EssentialsX"
    plugins["luckperms"]="LuckPerms"
    plugins["vault"]="Vault"
    plugins["viaversion"]="ViaVersion"
    plugins["viabackwards"]="ViaBackwards"
    
    # Paper/Spigot/Purpur specific plugins
    if [[ "$server_type" == "paper" || "$server_type" == "spigot" || "$server_type" == "purpur" ]]; then
        plugins["worldedit"]="WorldEdit"
        plugins["chunky"]="Chunky"
    fi
    
    # Get versions for each plugin based on Minecraft version
    for plugin in "${!plugins[@]}"; do
        plugin_versions[$plugin]=$(get_plugin_version "$plugin" "$mc_version" "latest")
    done
    
    # Download each plugin with progress indicator
    local total_plugins=${#plugins[@]}
    local current=1
    local success_count=0
    
    for plugin in "${!plugins[@]}"; do
        local plugin_version="${plugin_versions[$plugin]}"
        local plugin_url
        plugin_url=$(get_plugin_url "$plugin" "$plugin_version")
        
        echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Downloading ${BOLD_CYAN}${plugins[$plugin]}${RESET} v${BOLD_CYAN}${plugin_version}${RESET} (${current}/${total_plugins})..."
        
        if [ -n "$plugin_url" ]; then
            if download_with_retry "$plugin_url" "plugins/${plugin}.jar"; then
                echo -e "  ${BOLD_GREEN}${CHECK_MARK} ${RESET}${plugins[$plugin]} v${plugin_version} installed successfully!"
                success_count=$((success_count + 1))
            else
                echo -e "  ${BOLD_RED}${CROSS_MARK} ${RESET}Failed to download ${plugins[$plugin]}"
            fi
        else
            echo -e "  ${BOLD_RED}${CROSS_MARK} ${RESET}No download URL found for ${plugins[$plugin]}"
        fi
        
        current=$((current + 1))
    done
    
    echo
    if [ $success_count -eq ${#plugins[@]} ]; then
        echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}All plugins installed successfully!"
    else
        echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Installed ${BOLD_CYAN}${success_count}${RESET} out of ${BOLD_CYAN}${#plugins[@]}${RESET} plugins."
    fi
    
    return 0
}

# Function to configure server properties
configure_server() {
    local server_type
    server_type=$(cat .server-type 2>/dev/null || echo "unknown")
    
    print_header "Server Configuration" "$BOLD_CYAN" "$GEAR"
    
    echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Configuring ${BOLD_CYAN}${server_type^}${RESET} server..."
    
    # Ask about cracked mode
    local online_mode="true"
    if get_yes_no "Enable cracked mode (allows non-premium Minecraft accounts)?" "n"; then
        online_mode="false"
        echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Cracked mode enabled (online-mode=false)"
    else
        echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Premium mode enabled (online-mode=true)"
    fi
    
    # Create server.properties for Minecraft servers
    if [[ "$server_type" != "bungeecord" && "$server_type" != "velocity" ]]; then
        if [ ! -f "server.properties" ]; then
            echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Creating server.properties file..."
            
            # Get server port
            local port=${SERVER_PORT:-$DEFAULT_PORT}
            
            cat > server.properties << EOL
#Minecraft server properties
#Generated by AuraNodes Ultimate Server Manager
#$(date)
server-port=${port}
motd=\\u00A7b\\u00A7lAuraNodes \\u00A78| \\u00A7fPremium Game Hosting
enable-command-block=true
spawn-protection=0
view-distance=10
simulation-distance=10
max-players=20
online-mode=${online_mode}
allow-flight=true
white-list=false
difficulty=normal
gamemode=survival
EOL
            echo -e "  ${BOLD_GREEN}${CHECK_MARK} ${RESET}server.properties created successfully!"
        else
            echo -e "  ${BOLD_BLUE}${ARROW} ${RESET}Updating existing server.properties..."
            # Update online-mode in existing server.properties
            sed -i "s/online-mode=.*/online-mode=${online_mode}/" server.properties
            echo -e "  ${BOLD_GREEN}${CHECK_MARK} ${RESET}server.properties updated successfully!"
        fi
    fi
    
    # Create config for BungeeCord
    if [ "$server_type" == "bungeecord" ] && [ ! -f "config.yml" ]; then
        echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Creating BungeeCord configuration..."
        
        # Get server port
        local port=${SERVER_PORT:-$DEFAULT_PORT}
        
        cat > config.yml << EOL
server_connect_timeout: 5000
listeners:
- query_port: 25577
  motd: '&b&lAuraNodes &8| &fPremium Game Hosting'
  tab_list: GLOBAL_PING
  query_enabled: false
  proxy_protocol: false
  forced_hosts:
    pvp.md-5.net: pvp
  ping_passthrough: false
  priorities:
  - lobby
  bind_local_address: true
  host: 0.0.0.0:${port}
  max_players: 500
  tab_size: 60
  force_default_server: false
online_mode: ${online_mode}
EOL
        echo -e "  ${BOLD_GREEN}${CHECK_MARK} ${RESET}BungeeCord config.yml created successfully!"
    elif [ "$server_type" == "bungeecord" ] && [ -f "config.yml" ]; then
        echo -e "  ${BOLD_BLUE}${ARROW} ${RESET}Updating existing BungeeCord config.yml..."
        # Update online_mode in existing config.yml
        sed -i "s/online_mode:.*/online_mode: ${online_mode}/" config.yml
        echo -e "  ${BOLD_GREEN}${CHECK_MARK} ${RESET}BungeeCord config.yml updated successfully!"
    fi
    
    # Create config for Velocity
    if [ "$server_type" == "velocity" ] && [ ! -f "velocity.toml" ]; then
        echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Creating Velocity configuration..."
        
        # Get server port
        local port=${SERVER_PORT:-$DEFAULT_PORT}
        
        cat > velocity.toml << EOL
# Velocity configuration
# Generated by AuraNodes Ultimate Server Manager

# The bind address for the server
bind = "0.0.0.0:${port}"

# The motd for the server
motd = "&b&lAuraNodes &8| &fPremium Game Hosting"

# The maximum number of players on the server
show-max-players = 500

# Whether to enable player info forwarding
player-info-forwarding-mode = "NONE"

# The forwarding secret for player info forwarding
forwarding-secret = ""

# Whether to announce server information to the proxy
announce-forge = false

# Whether to enable online mode
online-mode = ${online_mode}

# Whether to enable the query protocol
enable-query = false

# The port for the query protocol
query-port = 25577

# Whether to enable compression
enable-compression = true

# The threshold for compression
compression-threshold = 256

# The level of compression
compression-level = 3

# The timeout for connections
connection-timeout = 5000

# The timeout for read operations
read-timeout = 30000

# The servers to connect to
[servers]
  lobby = "127.0.0.1:25566"
  survival = "127.0.0.1:25567"
EOL
        echo -e "  ${BOLD_GREEN}${CHECK_MARK} ${RESET}Velocity configuration created successfully!"
    elif [ "$server_type" == "velocity" ] && [ -f "velocity.toml" ]; then
        echo -e "  ${BOLD_BLUE}${ARROW} ${RESET}Updating existing Velocity configuration..."
        # Update online-mode in existing velocity.toml
        sed -i "s/online-mode = .*/online-mode = ${online_mode}/" velocity.toml
        echo -e "  ${BOLD_GREEN}${CHECK_MARK} ${RESET}Velocity configuration updated successfully!"
    fi
    
    # Accept EULA
    echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Accepting Minecraft EULA..."
    echo "eula=true" > eula.txt
    echo -e "  ${BOLD_GREEN}${CHECK_MARK} ${RESET}EULA accepted!"
    
    # Create server icon if it doesn't exist
    if [ ! -f "server-icon.png" ]; then
        echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Downloading AuraNodes server icon..."
        if download_with_retry "https://i.imgur.com/4KbNMKs.png" "server-icon.png"; then
            echo -e "  ${BOLD_GREEN}${CHECK_MARK} ${RESET}Server icon downloaded!"
        else
            echo -e "  ${BOLD_YELLOW}${ARROW} ${RESET}Failed to download server icon. Skipping..."
        fi
    fi
    
    fancy_box "${SPARKLES} Server configured successfully! ${SPARKLES}" "$BOLD_GREEN"
    return 0
}

# Function to optimize server performance
optimize_server() {
    local server_type
    server_type=$(cat .server-type 2>/dev/null || echo "unknown")
    
    print_header "Performance Optimization" "$BOLD_CYAN" "$LIGHTNING"
    
    echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Applying performance optimizations for ${BOLD_CYAN}${server_type^}${RESET} server..."
    
    # Skip optimization for proxy servers
    if [[ "$server_type" == "bungeecord" || "$server_type" == "velocity" ]]; then
        echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Skipping optimization for proxy server"
        return 0
    fi
    
    # Paper/Purpur specific optimizations
    if [[ "$server_type" == "paper" || "$server_type" == "purpur" ]]; then
        echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Applying Paper/Purpur specific optimizations..."
        
        # Create paper-world-defaults.yml if it doesn't exist
        mkdir -p config
        if [ ! -f "config/paper-world-defaults.yml" ]; then
            cat > config/paper-world-defaults.yml << EOL
# AuraNodes optimized Paper world settings
entities:
  spawning:
    despawn-ranges:
      soft: 28
      hard: 96
  behavior:
    villagers:
      can-gather-experience: false
    pillagers:
      patrol:
        per-player: false
        spawn-delay:
          per-player: true
          ticks: 12000
    mob-effects:
      undead-immune-to-certain-effects: true
      spiders-immune-to-poison-effect: true
    zombies:
      target-turtle-eggs: false
    zombie-villagers:
      cure-time:
        min: 6000
        max: 6000
    entities-target-with-follow-range: false
    phantoms:
      spawn-delay-ticks: 500
      spawn-distance-horizontal: 20
      spawn-distance-vertical: 20
    experience-merge-max-value: 1000
    disable-chest-cat-detection: true
    armor-stands-tick: false
    tick-rates:
      sensor:
        villager:
          secondarypoisensor: 40
      behavior:
        villager:
          validatenearbypoi: 60
          acquirepoi: 120
    per-player-mob-spawns: true
  ticks-per:
    hopper:
      transfer: 8
      check: 8
      amount: 1
    villagers: 4
    water-checks: 20
    village:
      size-checks: 40
  activation-range:
    wake-up-inactive:
      animals-max-per-tick: 4
      animals-every: 1200
      animals-for: 100
      monsters-max-per-tick: 8
      monsters-every: 400
      monsters-for: 100
      villagers-max-per-tick: 4
      villagers-every: 600
      villagers-for: 100
      flying-monsters-max-per-tick: 8
      flying-monsters-every: 200
      flying-monsters-for: 100
    villagers-work-immunity-after: 100
    villagers-work-immunity-for: 20
    villagers-active-for-panic: true
    animals: 16
    monsters: 24
    raiders: 48
    misc: 8
    water: 8
    villagers: 16
    flying-monsters: 48
    tick-inactive-villagers: false
    ignore-spectators: true
  alt-item-despawn-rate:
    enabled: true
    items:
      cobblestone: 300
      netherrack: 300
      dirt: 300
      sand: 300
      red_sand: 300
      gravel: 300
      grass: 300
      stone: 300
      stone_variants: 300
      seeds: 600
  unsupported-settings:
    fix-invulnerable-end-crystal-exploit: true
chunks:
  auto-save-interval: 6000
  delay-chunk-unloads-by: 10
  max-auto-save-chunks-per-tick: 8
  prevent-moving-into-unloaded-chunks: true
  entity-per-chunk-save-limit:
    experience_orb: 16
    snowball: 16
    ender_pearl: 16
    arrow: 16
    fireball: 16
    small_fireball: 16
    egg: 16
collisions:
  enable-player-collisions: false
  send-full-pos-for-hard-colliding-entities: true
  fix-climbing-bypassing-cramming-rule: true
tick-rates:
  mob-spawner: 2
  container-update: 1
  grass-spread: 4
  mob-effects: 2
EOL
            echo -e "  ${BOLD_GREEN}${CHECK_MARK} ${RESET}Created optimized paper-world-defaults.yml"
        fi
        
        # Create paper-global.yml if it doesn't exist
        if [ ! -f "config/paper-global.yml" ]; then
            cat > config/paper-global.yml << EOL
# AuraNodes optimized Paper global settings  ]; then
            cat > config/paper-global.yml << EOL
# AuraNodes optimized Paper global settings
proxies:
  bungee-cord:
    online-mode: false
  velocity:
    enabled: false
    online-mode: false
    secret: ''
messages:
  kick:
    authentication-servers-down: '&cMinecraft authentication servers are down. Please try again later!\n&eAuraNodes'
    connection-throttle: '&cToo many login attempts. Please try again later!\n&eAuraNodes'
    flying-player: '&cFlying is not enabled on this server!\n&eAuraNodes'
    flying-vehicle: '&cFlying is not enabled on this server!\n&eAuraNodes'
timings:
  enabled: true
  verbose: false
  server-name-privacy: false
  hidden-config-entries:
  - database
  - proxies.velocity.secret
  history-interval: 300
  history-length: 3600
  server-name: AuraNodes
EOL
            echo -e "  ${BOLD_GREEN}${CHECK_MARK} ${RESET}Created optimized paper-global.yml"
        fi
        
        # Create spigot.yml if it doesn't exist
        if [ ! -f "spigot.yml" ]; then
            cat > spigot.yml << EOL
# AuraNodes optimized Spigot settings
settings:
  debug: false
  save-user-cache-on-stop-only: true
  sample-count: 12
  player-shuffle: 400
  user-cache-size: 1000
  moved-wrongly-threshold: 0.0625
  moved-too-quickly-multiplier: 10.0
  timeout-time: 60
  restart-on-crash: true
  restart-script: ./start.sh
  netty-threads: 4
  attribute:
    maxHealth:
      max: 2048.0
    movementSpeed:
      max: 2048.0
    attackDamage:
      max: 2048.0
  bungeecord: false
  log-villager-deaths: false
  log-named-deaths: true
messages:
  whitelist: '&cThis server is whitelisted!\n&eAuraNodes'
  unknown-command: '&cUnknown command. Type "/help" for help.'
  server-full: '&cThe server is full!\n&eAuraNodes'
  outdated-client: '&cOutdated client! Please use {0}\n&eAuraNodes'
  outdated-server: '&cOutdated server! I''m still on {0}\n&eAuraNodes'
  restart: '&cServer is restarting!\n&eAuraNodes'
advancements:
  disable-saving: false
  disabled:
  - minecraft:story/disabled
commands:
  spam-exclusions:
  - /skill
  replace-commands:
  - setblock
  - summon
  - testforblock
  - tellraw
  log: true
  tab-complete: 0
  send-namespaced: true
  silent-commandblock-console: false
players:
  disable-saving: false
world-settings:
  default:
    verbose: false
    enable-zombie-pigmen-portal-spawns: true
    item-despawn-rate: 6000
    view-distance: default
    wither-spawn-sound-radius: 0
    arrow-despawn-rate: 300
    trident-despawn-rate: 1200
    hanging-tick-frequency: 100
    zombie-aggressive-towards-villager: true
    nerf-spawner-mobs: true
    mob-spawn-range: 6
    end-portal-sound-radius: 0
    growth:
      cactus-modifier: 100
      cane-modifier: 100
      melon-modifier: 100
      mushroom-modifier: 100
      pumpkin-modifier: 100
      sapling-modifier: 100
      beetroot-modifier: 100
      carrot-modifier: 100
      potato-modifier: 100
      wheat-modifier: 100
      netherwart-modifier: 100
      vine-modifier: 100
      cocoa-modifier: 100
      bamboo-modifier: 100
      sweetberry-modifier: 100
      kelp-modifier: 100
    entity-activation-range:
      animals: 16
      monsters: 24
      raiders: 48
      misc: 8
      water: 8
      villagers: 16
      flying-monsters: 48
      wake-up-inactive:
        animals-max-per-tick: 4
        animals-every: 1200
        animals-for: 100
        monsters-max-per-tick: 8
        monsters-every: 400
        monsters-for: 100
        villagers-max-per-tick: 4
        villagers-every: 600
        villagers-for: 100
        flying-monsters-max-per-tick: 8
        flying-monsters-every: 200
        flying-monsters-for: 100
      villagers-work-immunity-after: 100
      villagers-work-immunity-for: 20
      villagers-active-for-panic: true
      tick-inactive-villagers: false
      ignore-spectators: true
    entity-tracking-range:
      players: 48
      animals: 48
      monsters: 48
      misc: 32
      other: 64
    ticks-per:
      hopper-transfer: 8
      hopper-check: 8
    hopper-amount: 1
    hopper-can-load-chunks: false
    max-tick-time:
      tile: 50
      entity: 50
    squid-spawn-range:
      min: 45.0
    merge-radius:
      exp: 3.0
      item: 2.5
EOL
            echo -e "  ${BOLD_GREEN}${CHECK_MARK} ${RESET}Created optimized spigot.yml"
        fi
    fi
    
    # Create bukkit.yml if it doesn't exist (for Spigot/Paper/Purpur)
    if [[ "$server_type" == "spigot" || "$server_type" == "paper" || "$server_type" == "purpur" ]] && [ ! -f "bukkit.yml" ]; then
        cat > bukkit.yml << EOL
# AuraNodes optimized Bukkit settings
settings:
  allow-end: true
  warn-on-overload: true
  permissions-file: permissions.yml
  update-folder: update
  plugin-profiling: false
  connection-throttle: 4000
  query-plugins: true
  deprecated-verbose: default
  shutdown-message: '&cServer closed!\n&eAuraNodes'
  minimum-api: none
  use-map-color-cache: true
spawn-limits:
  monsters: 50
  animals: 10
  water-animals: 5
  water-ambient: 10
  water-underground-creature: 5
  ambient: 1
chunk-gc:
  period-in-ticks: 400
ticks-per:
  animal-spawns: 400
  monster-spawns: 100
  water-spawns: 400
  water-ambient-spawns: 400
  water-underground-creature-spawns: 400
  ambient-spawns: 400
  autosave: 6000
aliases: now-in-commands.yml
EOL
        echo -e "  ${BOLD_GREEN}${CHECK_MARK} ${RESET}Created optimized bukkit.yml"
    fi
    
    echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Server optimizations applied successfully!"
    return 0
}

# Function to start the server
start_server() {
    local server_type
    server_type=$(cat .server-type 2>/dev/null || echo "unknown")
    
    print_header "Server Startup" "$BOLD_CYAN" "$ROCKET"
    
    echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Starting ${BOLD_CYAN}${server_type^}${RESET} server..."
    
    # Set memory allocation
    if [ -z "$MEMORY" ]; then
        MEMORY="$DEFAULT_MEMORY"
    fi
    
    echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Memory allocation: ${BOLD_CYAN}${MEMORY}${RESET}"
    echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Using optimized startup flags"
    
    # Start the server based on type
    case $server_type in
        "paper"|"spigot"|"purpur"|"vanilla")
            echo -e "${BOLD_GREEN}${ROCKET} ${RESET}Launching server with command:"
            echo -e "  ${BOLD_WHITE}java -Xms512M -Xmx${MEMORY} [optimized flags] -jar server.jar nogui${RESET}"
            echo
            java -Xms512M -Xmx$MEMORY ${JAVA_FLAGS[@]} -jar server.jar nogui
            ;;
        "forge")
            local forge_jar
            if [ -f ".forge-jar" ]; then
                forge_jar=$(cat .forge-jar)
            else
                forge_jar=$(find . -name "forge-*.jar" | grep -v installer | head -1)
                if [ -z "$forge_jar" ]; then
                    forge_jar="server.jar"
                fi
            fi
            
            echo -e "${BOLD_GREEN}${ROCKET} ${RESET}Launching Forge server with command:"
            
            if [ -f "user_jvm_args.txt" ]; then
                echo -e "  ${BOLD_WHITE}java -Xms512M -Xmx${MEMORY} [optimized flags] @user_jvm_args.txt @libraries/net/minecraftforge/forge/*/unix_args.txt nogui${RESET}"
                echo
                java -Xms512M -Xmx$MEMORY ${JAVA_FLAGS[@]} @user_jvm_args.txt @libraries/net/minecraftforge/forge/*/unix_args.txt nogui
            else
                echo -e "  ${BOLD_WHITE}java -Xms512M -Xmx${MEMORY} [optimized flags] -jar ${forge_jar} nogui${RESET}"
                echo
                java -Xms512M -Xmx$MEMORY ${JAVA_FLAGS[@]} -jar $forge_jar nogui
            fi
            ;;
        "fabric")
            echo -e "${BOLD_GREEN}${ROCKET} ${RESET}Launching Fabric server with command:"
            
            if [ -f "fabric-server-launch.jar" ]; then
                echo -e "  ${BOLD_WHITE}java -Xms512M -Xmx${MEMORY} [optimized flags] -jar fabric-server-launch.jar nogui${RESET}"
                echo
                java -Xms512M -Xmx$MEMORY ${JAVA_FLAGS[@]} -jar fabric-server-launch.jar nogui
            else
                echo -e "  ${BOLD_WHITE}java -Xms512M -Xmx${MEMORY} [optimized flags] -jar server.jar nogui${RESET}"
                echo
                java -Xms512M -Xmx$MEMORY ${JAVA_FLAGS[@]} -jar server.jar nogui
            fi
            ;;
        "bungeecord"|"velocity")
            echo -e "${BOLD_GREEN}${ROCKET} ${RESET}Launching proxy server with command:"
            echo -e "  ${BOLD_WHITE}java -Xms512M -Xmx${MEMORY} -jar server.jar${RESET}"
            echo
            java -Xms512M -Xmx$MEMORY -jar server.jar
            ;;
        *)
            echo -e "${BOLD_RED}${CROSS_MARK} Unknown server type: $server_type${RESET}"
            return 1
            ;;
    esac
    
    return 0
}

# Function to create a backup
create_backup() {
    print_header "Server Backup" "$BOLD_CYAN" "$SHIELD"
    
    local backup_dir="backups"
    mkdir -p "$backup_dir"
    
    local timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
    local backup_file="${backup_dir}/server_backup_${timestamp}.tar.gz"
    
    echo -e "${BOLD_YELLOW}${ARROW} ${RESET}Creating server backup..."
    
    # Check if tar command exists
    if ! command_exists tar; then
        echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}The 'tar' command is not available. Cannot create backup."
        return 1
    fi
    
    # Exclude large and unnecessary files
    start_spinner "Creating backup archive"
    if ! tar --exclude="./backups" --exclude="./cache" --exclude="./logs" --exclude="./crash-reports" \
        --exclude="./libraries" --exclude="./versions" --exclude="./world/region" \
        -czf "$backup_file" .; then
        stop_spinner
        echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to create backup"
        return 1
    fi
    stop_spinner
    
    if [ -f "$backup_file" ]; then
        local size
        if command_exists du; then
            size=$(du -h "$backup_file" | cut -f1)
        else
            size=$(ls -lh "$backup_file" | awk '{print $5}')
        fi
        echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Backup created successfully: ${BOLD_CYAN}${backup_file}${RESET} (${size})"
    else
        echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Failed to create backup"
        return 1
    fi
    
    return 0
}

# Function to display server status
show_server_status() {
    print_header "Server Status" "$BOLD_CYAN" "$GEAR"
    
    if [ -f ".server-type" ]; then
        local server_type
        server_type=$(cat .server-type 2>/dev/null || echo "unknown")
        echo -e "${BOLD_WHITE}Server Type:${RESET} ${BOLD_CYAN}${server_type^}${RESET}"
    else
        echo -e "${BOLD_WHITE}Server Type:${RESET} ${BOLD_RED}Not installed${RESET}"
        return 1
    fi
    
    if [ -f ".mc-version" ]; then
        local mc_version
        mc_version=$(cat .mc-version 2>/dev/null || echo "unknown")
        echo -e "${BOLD_WHITE}Minecraft Version:${RESET} ${BOLD_CYAN}${mc_version}${RESET}"
    fi
    
    # Check if server is running
    if command_exists pgrep && pgrep -f "java.*server.jar" > /dev/null; then
        echo -e "${BOLD_WHITE}Status:${RESET} ${BOLD_GREEN}Running${RESET}"
        
        # Get memory usage
        if command_exists ps; then
            local pid
            pid=$(pgrep -f "java.*server.jar")
            if [ -n "$pid" ]; then
                local mem_usage
                mem_usage=$(ps -o rss= -p "$pid" 2>/dev/null | awk '{print int($1/1024)}')
                if [ -n "$mem_usage" ]; then
                    echo -e "${BOLD_WHITE}Memory Usage:${RESET} ${BOLD_CYAN}${mem_usage} MB${RESET}"
                fi
            fi
        fi
    else
        echo -e "${BOLD_WHITE}Status:${RESET} ${BOLD_RED}Stopped${RESET}"
    fi
    
    # Check world size if exists
    if [ -d "world" ] && command_exists du; then
        local world_size
        world_size=$(du -sh world 2>/dev/null | cut -f1)
        if [ -n "$world_size" ]; then
            echo -e "${BOLD_WHITE}World Size:${RESET} ${BOLD_CYAN}${world_size}${RESET}"
        fi
    fi
    
    # Check plugin count
    if [ -d "plugins" ] && command_exists find; then
        local plugin_count
        plugin_count=$(find plugins -name "*.jar" 2>/dev/null | wc -l)
        if [ -n "$plugin_count" ]; then
            echo -e "${BOLD_WHITE}Plugins:${RESET} ${BOLD_CYAN}${plugin_count}${RESET}"
        fi
    fi
    
    return 0
}

# Function to handle server selection and installation
select_and_install_server() {
    # Display server type selection menu
    server_options=(
        "${GREEN}Paper${RESET} - High performance fork with plugin support (Recommended)"
        "${YELLOW}Forge${RESET} - For modded Minecraft"
        "${BLUE}Fabric${RESET} - Lightweight, modular mod loader"
        "${PURPLE}Purpur${RESET} - Fork of Paper with additional features"
        "${WHITE}Vanilla${RESET} - Official Minecraft server"
        "${RED}Spigot${RESET} - Optimized CraftBukkit fork"
        "${CYAN}BungeeCord${RESET} - Proxy server for connecting multiple servers"
        "${BLUE}Velocity${RESET} - Modern, high-performance proxy server"
    )
    
    display_menu "Select Server Software" "$ROCKET" "${server_options[@]}"
    read -r choice
    
    case $choice in
        1) server_type="paper";;
        2) server_type="forge";;
        3) server_type="fabric";;
        4) server_type="purpur";;
        5) server_type="vanilla";;
        6) server_type="spigot";;
        7) server_type="bungeecord";;
        8) server_type="velocity";;
        *) 
            echo -e "${BOLD_RED}${CROSS_MARK} Invalid choice. Defaulting to Paper.${RESET}"
            sleep 2
            server_type="paper"
            ;;
    esac
    
    # Get Minecraft version with proper input handling
    mc_version=""
    while [ -z "$mc_version" ]; do
        mc_version=$(get_input "Enter Minecraft version (e.g., 1.20.4) or press Enter for latest" "$DEFAULT_MC_VERSION" validate_version)
    done
    
    # Install server
    if ! install_server "$server_type" "$mc_version"; then
        echo -e "${BOLD_RED}${CROSS_MARK} ${RESET}Server installation failed. Please check the logs above."
        return 1
    fi
    
    # Install plugins
    install_plugins
    
    # Configure server
    configure_server
    
    # Optimize server
    optimize_server
    
    # Ask to start server
    if get_yes_no "Start the server now?" "y"; then
        start_server
    else
        echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Server setup completed. Run the script again to start the server."
    fi
    
    return 0
}

# Main function
main() {
    # Set environment variables from Pterodactyl if available
    MEMORY=${MEMORY:-$DEFAULT_MEMORY}
    SERVER_PORT=${SERVER_PORT:-$DEFAULT_PORT}
    
    # Display banner
    show_banner
    
    # Check dependencies (but don't exit if some are missing)
    check_dependencies
    
    # Setup Java
    setup_java
    
    # Check if server is already installed
    if [ -f ".server-type" ]; then
        show_server_status
        
        # Display main menu
        echo
        main_options=(
            "${GREEN}Start Server${RESET} - Launch the existing server"
            "${YELLOW}Reinstall Server${RESET} - Change server software or version"
            "${BLUE}Manage Plugins${RESET} - Install or update plugins"
            "${PURPLE}Server Settings${RESET} - Configure server properties"
            "${CYAN}Optimize Server${RESET} - Apply performance optimizations"
            "${RED}Create Backup${RESET} - Backup server files"
            "${WHITE}Exit${RESET} - Exit without starting the server"
        )
        
        display_menu "Main Menu" "$CROWN" "${main_options[@]}"
        read -r choice
        
        case $choice in
            1) # Start server
                configure_server
                start_server
                ;;
            2) # Reinstall server
                select_and_install_server
                ;;
            3) # Manage plugins
                install_plugins
                if get_yes_no "Start the server now?" "y"; then
                    start_server
                fi
                ;;
            4) # Server settings
                configure_server
                if get_yes_no "Start the server now?" "y"; then
                    start_server
                fi
                ;;
            5) # Optimize server
                optimize_server
                if get_yes_no "Start the server now?" "y"; then
                    start_server
                fi
                ;;
            6) # Create backup
                create_backup
                if get_yes_no "Start the server now?" "y"; then
                    start_server
                fi
                ;;
            7) # Exit
                echo -e "${BOLD_GREEN}${CHECK_MARK} ${RESET}Exiting AuraNodes Server Manager. Goodbye!"
                exit 0
                ;;
            *) # Invalid choice
                echo -e "${BOLD_RED}${CROSS_MARK} Invalid choice. Starting server with current configuration.${RESET}"
                sleep 2
                configure_server
                start_server
                ;;
        esac
    else
        select_and_install_server
    fi
}

# Execute main function
main
