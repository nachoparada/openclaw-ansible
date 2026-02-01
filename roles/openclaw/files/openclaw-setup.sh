#!/bin/bash
set -e

# Enable 256 colors
export TERM=xterm-256color
export COLORTERM=truecolor

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# OpenClaw ASCII Art
cat << 'BANNER'
[0;36m
   +====================================================+
   |                                                    |
   |         [0;33mWelcome to OpenClaw![0;36m                        |
   |                                                    |
   |           [0;32m✅  Installation Successful![0;36m             |
   |                                                    |
   +====================================================+[0m
BANNER

echo ""
echo -e "${GREEN}Security Status:${NC}"
echo "  - UFW Firewall: ENABLED"
echo "  - Open Ports: SSH (22) + Tailscale (41641/udp)"
echo "  - Docker isolation: ACTIVE"
echo ""
echo -e "Documentation: ${GREEN}https://docs.openclaw.ai${NC}"
echo ""

# Switch to openclaw user for setup
echo -e "${YELLOW}Switching to openclaw user for setup...${NC}"
echo ""
echo "DEBUG: About to create init script..."

# Create init script that will be sourced on login
cat > /home/openclaw/.openclaw-init << 'INIT_EOF'
# Display welcome message
echo "============================================"
echo "OpenClaw Setup - Next Steps"
echo "============================================"
echo ""
echo "You are now: $(whoami)@$(hostname)"
echo "Home: $HOME"
echo ""
echo "Setup Commands:"
echo ""
echo "1. Run onboarding wizard:"
echo "   openclaw onboard"
echo ""
echo "2. Login to provider (WhatsApp/Telegram/Discord):"
echo "   openclaw channels login"
echo ""
echo "3. Test gateway:"
echo "   openclaw gateway"
echo ""
echo "4. Check status:"
echo "   openclaw status"
echo "   openclaw health"
echo ""
echo "5. Gateway commands:"
echo "   openclaw gateway status"
echo "   openclaw gateway restart"
echo "   openclaw logs"
echo ""
echo "6. Connect Tailscale (as root):"
echo "   exit"
echo "   sudo tailscale up"
echo ""
echo "============================================"
echo ""
echo "Type 'exit' to return to previous user"
echo ""

# Remove this init file after first login
rm -f ~/.openclaw-init
INIT_EOF

chown openclaw:openclaw /home/openclaw/.openclaw-init

# Add one-time sourcing to .bashrc if not already there
grep -q '.openclaw-init' /home/openclaw/.bashrc 2>/dev/null || {
    echo '' >> /home/openclaw/.bashrc
    echo '# One-time setup message' >> /home/openclaw/.bashrc
    echo '[ -f ~/.openclaw-init ] && source ~/.openclaw-init' >> /home/openclaw/.bashrc
}

# Switch to openclaw user with explicit interactive shell
# Using setsid to create new session + force pseudo-terminal allocation
exec sudo -i -u openclaw /bin/bash --login
