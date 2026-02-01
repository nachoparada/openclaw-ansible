---
title: Troubleshooting
description: Common issues and solutions
---

# Troubleshooting

## OpenClaw Can't Reach Internet

**Symptom**: OpenClaw can't connect to WhatsApp/Telegram

**Check**:
```bash
# Test network connectivity
curl -I https://api.anthropic.com

# Check UFW allows outbound
sudo ufw status verbose | grep OUT
```

**Solution**:
```bash
# Verify DOCKER-USER allows established connections
sudo iptables -L DOCKER-USER -n -v

# Restart Docker + Firewall
sudo systemctl restart docker
sudo ufw reload
```

## Port Already in Use

**Symptom**: Port 18789 conflict

**Solution**:
```bash
# Find what's using port 18789
sudo ss -tlnp | grep 18789

# Change OpenClaw gateway port in config
sudo su - openclaw
nano ~/.openclaw/openclaw.json
# Change gateway.port

# Restart gateway
openclaw gateway restart
```

## Firewall Lockout

**Symptom**: Can't SSH after installation

**Solution** (via console/rescue mode):
```bash
# Disable UFW temporarily
sudo ufw disable

# Check SSH rule exists
sudo ufw status numbered

# Re-add SSH rule
sudo ufw allow 22/tcp

# Re-enable
sudo ufw enable
```

## Gateway Won't Start

**Check logs**:
```bash
# Check gateway status
openclaw gateway status

# View logs
openclaw logs

# Check systemd logs
journalctl --user -u openclaw-gateway -n 50
```

**Common fixes**:
```bash
# Check permissions
ls -la ~/.openclaw/

# Fix permissions
chmod 600 ~/.openclaw/openclaw.json
chmod 700 ~/.openclaw/credentials

# Reinstall gateway service
openclaw gateway install
openclaw gateway start
```

## Verify Docker Isolation

**Test that external ports are blocked**:
```bash
# Start test container
sudo docker run -d -p 80:80 --name test-nginx nginx

# From EXTERNAL machine (should fail):
curl http://YOUR_SERVER_IP:80

# From SERVER (should work):
curl http://localhost:80

# Cleanup
sudo docker rm -f test-nginx
```

## UFW Status Shows Inactive

**Fix**:
```bash
# Enable UFW
sudo ufw enable

# Reload rules
sudo ufw reload

# Verify
sudo ufw status verbose
```

## Ansible Playbook Fails

**Collection missing**:
```bash
ansible-galaxy collection install -r requirements.yml
```

**Permission denied**:
```bash
# Run with --ask-become-pass
ansible-playbook playbook.yml --ask-become-pass
```

**Docker daemon not running**:
```bash
sudo systemctl start docker
# Re-run playbook
```

## OpenClaw Command Not Found

**Symptom**: `openclaw: command not found`

**Solution**:
```bash
# Check if ~/.local/bin is in PATH
echo $PATH | grep ".local/bin"

# Add to PATH if missing
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Verify installation
which openclaw
openclaw --version
```

## Channel Login Issues

**WhatsApp QR code not appearing**:
```bash
# Try restarting gateway first
openclaw gateway restart

# Then run login
openclaw channels login
```

**Telegram bot not responding**:
```bash
# Check bot token is configured
openclaw status

# Check pairing status
openclaw pairing list telegram
```

## Health Check Fails

**Run diagnostics**:
```bash
# Quick status check
openclaw status

# Detailed health check
openclaw health

# Full diagnostic report
openclaw status --all

# Run doctor
openclaw doctor
```

## Session/Context Issues

**Reset a session**:
```bash
# Send /reset or /new in the chat
# Or manually:
rm ~/.openclaw/agents/*/sessions/<session-id>.jsonl
```

## Development Mode Issues

**Build fails**:
```bash
cd ~/code/openclaw

# Clean install
rm -rf node_modules
pnpm install
pnpm build
```

**Symlink broken**:
```bash
# Recreate symlink
rm ~/.local/bin/openclaw
ln -sf ~/code/openclaw/openclaw.mjs ~/.local/bin/openclaw
chmod +x ~/code/openclaw/openclaw.mjs
```
