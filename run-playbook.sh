#!/bin/bash
set -e

# Ensure Ansible is installed before running the playbook
if ! command -v ansible-playbook &> /dev/null; then
    if [ "$EUID" -eq 0 ]; then
        SUDO=""
    else
        if ! command -v sudo &> /dev/null; then
            echo "Error: sudo is not installed. Please install sudo or run as root."
            exit 1
        fi
        SUDO="sudo"
    fi

    if command -v apt-get &> /dev/null; then
        echo "Ansible not found. Installing via apt..."
        $SUDO apt-get update -qq
        $SUDO apt-get install -y ansible
    elif command -v brew &> /dev/null; then
        echo "Ansible not found. Installing via Homebrew..."
        brew install ansible
    else
        echo "Error: Ansible not found and no supported package manager detected."
        echo "Install Ansible manually, then re-run this script."
        exit 1
    fi
fi

# Ensure required collections are installed
if [ -f requirements.yml ]; then
    echo "Installing Ansible collections..."
    ansible-galaxy collection install -r requirements.yml
fi

# Run the Ansible playbook
if [ "$EUID" -eq 0 ]; then
    ansible-playbook playbook.yml -e ansible_become=false "$@"
    PLAYBOOK_EXIT=$?
else
    ansible-playbook playbook.yml --ask-become-pass "$@"
    PLAYBOOK_EXIT=$?
fi

# After playbook completes successfully, show instructions
if [ $PLAYBOOK_EXIT -eq 0 ]; then
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "✅ INSTALLATION COMPLETE!"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo "🔄 SWITCH TO OPENCLAW USER with:"
    echo ""
    echo "    sudo su - openclaw"
    echo ""
    echo "  OR (alternative):"
    echo ""
    echo "    sudo -u openclaw -i"
    echo ""
    echo "This will switch you to the openclaw user with a proper"
    echo "login shell (loads .bashrc, sets environment correctly)."
    echo ""
    echo "After switching, you'll see the next setup steps:"
    echo "  • Configure OpenClaw (~/.openclaw/openclaw.json)"
    echo "  • Login to messaging channel (WhatsApp/Telegram/Discord)"
    echo "  • Test the gateway"
    echo "  • Connect Tailscale VPN"
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo ""
else
    echo "❌ Playbook failed with exit code $PLAYBOOK_EXIT"
    exit $PLAYBOOK_EXIT
fi
