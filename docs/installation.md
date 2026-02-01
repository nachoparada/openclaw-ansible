---
title: Installation Guide
description: Detailed installation and configuration instructions
---

# Installation Guide

## Quick Install

### Recommended (Clone and Run)

```bash
git clone https://github.com/nachoparada/openclaw-ansible.git
cd openclaw-ansible

./run-playbook.sh
```

Pass variables as needed:

```bash
./run-playbook.sh -e tailscale_authkey=tskey-auth-xxxxx
```

### Defaults Only (One-Liner)

```bash
curl -fsSL https://raw.githubusercontent.com/nachoparada/openclaw-ansible/main/install.sh | bash
```

## Manual Installation

### Prerequisites

```bash
sudo apt update
sudo apt install -y ansible git
```

### Clone and Run

```bash
git clone https://github.com/openclaw/openclaw-ansible.git
cd openclaw-ansible

# Install Ansible collections
ansible-galaxy collection install -r requirements.yml

# Run playbook
ansible-playbook playbook.yml --ask-become-pass
```

## Post-Installation

### 1. Connect to Tailscale

```bash
# Interactive login
sudo tailscale up

# Or with auth key for automation
sudo tailscale up --authkey tskey-auth-xxxxx

# Check status
sudo tailscale status
```

Get auth keys from: https://login.tailscale.com/admin/settings/keys

### 2. Switch to OpenClaw User

```bash
sudo su - openclaw
```

### 3. Configure OpenClaw

```bash
# Run onboarding wizard (recommended)
openclaw onboard --install-daemon

# Or configure manually
openclaw configure

# Edit config directly
nano ~/.openclaw/openclaw.json
```

### 4. Login to Channel

```bash
# Login to messaging channel (WhatsApp/Telegram/Discord)
openclaw channels login

# Check connection status
openclaw status
```

## Service Management

### OpenClaw Gateway Commands

```bash
# Check status
openclaw gateway status

# Start/stop/restart
openclaw gateway start
openclaw gateway stop
openclaw gateway restart

# View logs
openclaw logs
openclaw logs --follow

# Health check
openclaw health
openclaw doctor
```

### Firewall Management

```bash
# View UFW status
sudo ufw status verbose

# Add custom rule
sudo ufw allow 8080/tcp comment 'Custom service'
sudo ufw reload

# View Docker isolation
sudo iptables -L DOCKER-USER -n -v
```

## Accessing OpenClaw

OpenClaw's web interface runs on port 18789 (localhost only by default).

### Via Dashboard

```bash
# Open dashboard in browser
openclaw dashboard
```

### Via SSH Tunnel

```bash
ssh -L 18789:localhost:18789 user@server
# Then browse to: http://localhost:18789
```

### Via Tailscale Serve

```bash
# Expose via Tailscale Serve (HTTPS)
tailscale serve https / http://localhost:18789

# Access from any device on your Tailnet:
# https://your-machine-name.your-tailnet.ts.net/
```

## Verification

### Security Check

```bash
# Check open ports (should show only SSH + Tailscale)
sudo ss -tlnp

# External port scan (only port 22 should be open)
nmap -p- YOUR_SERVER_IP

# Test container isolation
sudo docker run -d -p 80:80 --name test-nginx nginx
curl http://YOUR_SERVER_IP:80  # Should fail
curl http://localhost:80        # Should work
sudo docker rm -f test-nginx
```

### UFW Status

```bash
sudo ufw status verbose

# Expected output:
# Status: active
# To                         Action      From
# --                         ------      ----
# 22/tcp                     ALLOW IN    Anywhere
# 41641/udp                  ALLOW IN    Anywhere
```

### Tailscale Status

```bash
sudo tailscale status

# Expected output:
# 100.x.x.x    hostname    user@        linux   -
```

## Uninstall

```bash
# Stop services
sudo su - openclaw
openclaw gateway stop

# Exit back to your user
exit

# Remove user and data
sudo userdel -r openclaw

# Remove Tailscale (optional)
sudo tailscale down
sudo apt remove --purge tailscale

# Remove packages (optional)
sudo apt remove --purge docker-ce docker-ce-cli containerd.io docker-compose-plugin nodejs

# Reset firewall (optional)
sudo ufw disable
sudo ufw --force reset
```

## Advanced Configuration

### Custom Gateway Port

Edit `~/.openclaw/openclaw.json`:

```json
{
  "gateway": {
    "port": 18790
  }
}
```

Then restart:
```bash
openclaw gateway restart
```

### Environment Variables

Set in your shell or service environment:

```bash
export ANTHROPIC_API_KEY=sk-ant-xxx
export DEBUG=openclaw:*
```

## Automation

### Unattended Install

```bash
# Set Tailscale auth key in playbook vars
ansible-playbook playbook.yml \
  --ask-become-pass \
  -e "tailscale_authkey=tskey-auth-xxxxx"
```

### CI/CD Integration

```yaml
# Example GitHub Actions
- name: Deploy OpenClaw
  run: |
    ansible-playbook playbook.yml \
      -e "tailscale_authkey=${{ secrets.TAILSCALE_KEY }}" \
      --become
```

## See Also

- [OpenClaw Documentation](https://docs.openclaw.ai)
- [Getting Started](https://docs.openclaw.ai/start/getting-started)
- [Configuration Guide](configuration.md)
- [Troubleshooting](troubleshooting.md)
