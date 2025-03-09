#!/bin/bash

# Secure script execution
set -euo pipefail
IFS=$'\n\t'

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then 
    echo "Please run with sudo or as root"
    exit 1
fi

# Required system packages
REQUIRED_PACKAGES=(
    "unzip"
    "curl"
    "wget"
    "java-17-openjdk"
    "bc"
    "screen"
)

# ANSI color codes with fallback for terminals that don't support colors
if [ -t 1 ]; then
    declare -A colors=(
        [reset]='\033[0m'
        [black]='\033[0;30m'
        [red]='\033[0;31m'
        [green]='\033[0;32m'
        [yellow]='\033[0;33m'
        [blue]='\033[0;34m'
        [purple]='\033[0;35m'
        [cyan]='\033[0;36m'
        [white]='\033[0;37m'
        [bold]='\033[1m'
        [dim]='\033[2m'
        [underline]='\033[4m'
        [blink]='\033[5m'
        [reverse]='\033[7m'
        [hidden]='\033[8m'
    )
else
    declare -A colors=(
        [reset]='' [black]='' [red]='' [green]='' [yellow]=''
        [blue]='' [purple]='' [cyan]='' [white]='' [bold]=''
        [dim]='' [underline]='' [blink]='' [reverse]='' [hidden]=''
    )
fi

# Logging functions
log_info() { echo -e "${colors[cyan]}[INFO]${colors[reset]} $1"; }
log_success() { echo -e "${colors[green]}[SUCCESS]${colors[reset]} $1"; }
log_warning() { echo -e "${colors[yellow]}[WARNING]${colors[reset]} $1"; }
log_error() { echo -e "${colors[red]}[ERROR]${colors[reset]} $1"; }

# Error handling
trap 'handle_error $? $LINENO $BASH_LINENO "$BASH_COMMAND" $(printf "::%s" ${FUNCNAME[@]:-})' ERR

handle_error() {
    local exit_code=$1
    local line_no=$2
    local bash_lineno=$3
    local last_command=$4
    local func_trace=$5
    log_error "Error occurred in script at line: $line_no"
    log_error "Last command executed: $last_command"
    log_error "Exit code: $exit_code"
    cleanup
    exit $exit_code
}

# Cleanup function
cleanup() {
    log_info "Performing cleanup..."
    # Remove temporary files
    rm -f /tmp/auranodes-*
    # Kill any hanging processes
    pkill -f "auranodes-tmp" || true
}

# Check and install required packages
check_dependencies() {
    log_info "Checking system dependencies..."
    local missing_packages=()
    
    for package in "${REQUIRED_PACKAGES[@]}"; do
        if ! command -v "${package%%-*}" &> /dev/null; then
            missing_packages+=("$package")
        fi
    done
    
    if [ ${#missing_packages[@]} -ne 0 ]; then
        log_warning "Installing missing packages: ${missing_packages[*]}"
        if command -v apt-get &> /dev/null; then
            apt-get update
            apt-get install -y "${missing_packages[@]}"
        elif command -v yum &> /dev/null; then
            yum install -y "${missing_packages[@]}"
        else
            log_error "Package manager not supported. Please install manually: ${missing_packages[*]}"
            exit 1
        fi
    fi
}

# Display fancy banner
show_banner() {
    clear
    cat << "EOF"
${colors[cyan]}${colors[bold]}
    ▄▄▄       █    ██  ██▀███   ▄▄▄       ███▄    █  ▒█████  ▓█████▄ ▓█████   ██████ 
   ▒████▄     ██  ▓██▒▓██ ▒ ██▒▒████▄     ██ ▀█   █ ▒██▒  ██▒▒██▀ ██▌▓█   ▀ ▒██    ▒ 
   ▒██  ▀█▄  ▓██  ▒██░▓██ ░▄█ ▒▒██  ▀█▄  ▓██  ▀█ ██▒▒██░  ██▒░██   █▌▒███   ░ ▓██▄   
   ░██▄▄▄▄██ ▓▓█  ░██░▒██▀▀█▄  ░██▄▄▄▄██ ▓██▒  ▐▌██▒▒██   ██░░▓█▄   ▌▒▓█  ▄   ▒   ██▒
    ▓█   ▓██▒▒▒█████▓ ░██▓ ▒██▒ ▓█   ▓██▒▒██░   ▓██░░ ████▓▒░░▒████▓ ░▒████▒▒██████▒▒
    ▒▒   ▓▒█░░▒▓▒ ▒ ▒ ░ ▒▓ ░▒▓░ ▒▒   ▓▒█░░ ▒░   ▒ ▒ ░ ▒░▒░▒░  ▒▒▓  ▒ ░░ ▒░ ░▒ ▒▓▒ ▒ ░
     ▒   ▒▒ ░░░▒░ ░ ░   ░▒ ░ ▒░  ▒   ▒▒ ░░ ░░   ░ ▒░  ░ ▒ ▒░  ░ ▒  ▒  ░ ░  ░░ ░▒  ░ ░
     ░   ▒    ░░░ ░ ░   ░░   ░   ░   ▒      ░   ░ ░ ░ ░ ░ ▒   ░ ░  ░    ░   ░  ░  ░  
         ░  ░   ░        ░           ░  ░         ░     ░ ░     ░       ░  ░      ░  
${colors[reset]}
EOF
    echo -e "${colors[cyan]}${colors[bold]}════════════════════════ PREMIUM GAME HOSTING ════════════════════════${colors[reset]}"
    echo
}

# Function to check Java version and set appropriate flags
setup_java() {
    log_info "Configuring Java environment..."
    
    # Detect Java version
    if ! command -v java &> /dev/null; then
        log_error "Java not found. Please install Java 17 or later."
        exit 1
    }
    
    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
    if [ "$JAVA_VERSION" -lt 17 ]; then
        log_warning "Java version $JAVA_VERSION detected. Recommended version is 17 or later."
    }
    
    # Optimize Java flags based on available memory
    TOTAL_MEMORY=$(free -m | awk '/^Mem:/{print $2}')
    if [ "$TOTAL_MEMORY" -gt 8192 ]; then
        MAX_MEMORY="4G"
    elif [ "$TOTAL_MEMORY" -gt 4096 ]; then
        MAX_MEMORY="2G"
    else
        MAX_MEMORY="1G"
    fi
    
    # Aikar's flags for optimal performance
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
}

# Function to detect and validate server type
detect_server() {
    log_info "Detecting server type..."
    
    if [ -f ".server-type" ]; then
        SERVER_TYPE=$(cat .server-type)
    elif [ -f "server.jar" ]; then
        # Analyze server.jar to determine type
        if unzip -p server.jar META-INF/MANIFEST.MF | grep -q "Paper"; then
            SERVER_TYPE="paper"
        elif unzip -p server.jar META-INF/MANIFEST.MF | grep -q "Forge"; then
            SERVER_TYPE="forge"
        elif unzip -p server.jar META-INF/MANIFEST.MF | grep -q "Fabric"; then
            SERVER_TYPE="fabric"
        else
            SERVER_TYPE="vanilla"
        fi
        echo "$SERVER_TYPE" > .server-type
    else
        log_error "No server jar found!"
        exit 1
    fi
    
    log_success "Detected server type: $SERVER_TYPE"
}

# Function to start the server
start_server() {
    log_info "Starting $SERVER_TYPE server..."
    
    # Create server session name
    SESSION_NAME="mc_${SERVER_TYPE}_$(date +%s)"
    
    # Check if server is already running
    if screen -list | grep -q "$SESSION_NAME"; then
        log_error "Server is already running!"
        exit 1
    }
    
    # Ensure eula is accepted
    if [ ! -f "eula.txt" ] || ! grep -q "eula=true" eula.txt; then
        echo "eula=true" > eula.txt
    }
    
    # Start server in screen session
    case "$SERVER_TYPE" in
        "paper"|"vanilla")
            screen -dmS "$SESSION_NAME" java "${JAVA_FLAGS[@]}" -Xms512M -Xmx"$MAX_MEMORY" -jar server.jar nogui
            ;;
        "forge")
            screen -dmS "$SESSION_NAME" java "${JAVA_FLAGS[@]}" -Xms512M -Xmx"$MAX_MEMORY" @user_jvm_args.txt @libraries/net/minecraftforge/forge/*/unix_args.txt nogui
            ;;
        "fabric")
            screen -dmS "$SESSION_NAME" java "${JAVA_FLAGS[@]}" -Xms512M -Xmx"$MAX_MEMORY" -jar fabric-server-launch.jar nogui
            ;;
        *)
            log_error "Unsupported server type: $SERVER_TYPE"
            exit 1
            ;;
    esac
    
    # Monitor startup
    log_info "Server starting... Monitoring startup process"
    tail -f logs/latest.log | while read -r line; do
        if echo "$line" | grep -q "Done"; then
            log_success "Server started successfully!"
            break
        elif echo "$line" | grep -q "Error"; then
            log_error "Server failed to start. Check logs for details."
            cleanup
            exit 1
        fi
    done
}

# Main execution
main() {
    # Set script permissions
    chmod 700 "$0"
    
    # Show banner
    show_banner
    
    # Check dependencies
    check_dependencies
    
    # Setup Java environment
    setup_java
    
    # Detect server type
    detect_server
    
    # Start server
    start_server
    
    # Add shutdown hook
    trap cleanup EXIT
}

# Execute main function
main "$@"
