#!/bin/bash
set -e

# OpenClaw Ansible Installer
# This script clones the repo and runs the playbook

# Enable 256 colors
export TERM=xterm-256color

# Force color support
if [ -z "$COLORTERM" ]; then
    export COLORTERM=truecolor
fi

REPO_URL="https://raw.githubusercontent.com/nachoparada/openclaw-ansible/main"
PLAYBOOK_URL="${REPO_URL}/playbook.yml"
TEMP_DIR=$(mktemp -d)

# Colors (with 256-color support)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   OpenClaw Ansible Installer           ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""

# Detect operating system
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macos"
    echo -e "${GREEN}Detected: macOS${NC}"
elif command -v apt-get &> /dev/null; then
    OS_TYPE="linux"
    echo -e "${GREEN}Detected: Debian/Ubuntu Linux${NC}"
else
    echo -e "${RED}Error: Unsupported operating system.${NC}"
    echo -e "${RED}This installer supports: Debian/Ubuntu and macOS${NC}"
    exit 1
fi

echo -e "${GREEN}[1/2] Downloading playbook...${NC}"

# Download the playbook and role files
cd "$TEMP_DIR"

# For simplicity, we'll clone the entire repo
echo "Cloning repository..."
git clone https://github.com/nachoparada/openclaw-ansible.git
cd openclaw-ansible

echo -e "${GREEN}✓ Playbook downloaded${NC}"

echo -e "${GREEN}[2/2] Running Ansible playbook...${NC}"
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}You will be prompted for your sudo password.${NC}"
fi
echo ""

# Run the playbook
./run-playbook.sh

# Cleanup
cd /
rm -rf "$TEMP_DIR"

# run-playbook.sh will display instructions to switch to openclaw user
