---
title: Security Architecture
description: Firewall configuration, SSH hardening, and Docker isolation details
---

# Security Architecture

## Overview

This playbook implements a multi-layer defense strategy to ensure only SSH (port 22) is accessible from the internet.

## SSH Hardening (Linux)

On Linux systems, the playbook automatically hardens SSH configuration:

- **Password authentication disabled**: Only SSH key authentication is allowed
- **Root login disabled**: Direct root SSH access is blocked

**Important**: Before running this playbook, ensure you have:

1. Configured your SSH keys in the `clawdbot_ssh_keys` variable
2. Tested SSH key access to avoid being locked out

```yaml
# Example: Configure SSH keys before running
clawdbot_ssh_keys:
  - "ssh-ed25519 AAAAC3... user@host"
```

**Note**: SSH hardening only runs on Debian-based Linux systems (Ubuntu, Debian).

## Firewall and Network Security

### Layer 1: UFW Firewall

```bash
# Default policies
Incoming: DENY
Outgoing: ALLOW
Routed: DENY

# Allowed
SSH (22/tcp): ALLOW
Tailscale (41641/udp): ALLOW
```

## Layer 2: DOCKER-USER Chain

Custom iptables chain that prevents Docker from bypassing UFW:

```
*filter
:DOCKER-USER - [0:0]
-A DOCKER-USER -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A DOCKER-USER -i lo -j ACCEPT
-A DOCKER-USER -i <default_interface> -j DROP
COMMIT
```

**Result**: Even `docker run -p 80:80 nginx` won't expose port 80 externally.

## Layer 3: Localhost-Only Binding

All container ports bind to 127.0.0.1:

```yaml
ports:
  - "127.0.0.1:3000:3000"
```

## Layer 4: Non-Root Container

Container processes run as unprivileged `clawdbot` user.

## Verification

```bash
# Check firewall
sudo ufw status verbose

# Check Tailscale status
sudo tailscale status

# Check Docker isolation
sudo iptables -L DOCKER-USER -n -v

# Port scan from external machine (only SSH + Tailscale should be open)
nmap -p- YOUR_SERVER_IP

# Test container isolation
sudo docker run -d -p 80:80 nginx
curl http://YOUR_SERVER_IP:80  # Should fail/timeout
curl http://localhost:80        # Should work
```

## Gateway Security

By default, the Clawdbot gateway is configured with secure defaults:

- **Loopback binding**: Gateway binds to 127.0.0.1, not accessible from network
- **Tailscale Serve**: Access gateway securely via Tailscale with HTTPS

### Configuration Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `clawdbot_gateway_bind` | `loopback` | Bind to 127.0.0.1 (secure) or 0.0.0.0 (network) |
| `clawdbot_gateway_mode` | `local` | `local` for localhost only, `network` for network access |
| `clawdbot_gateway_tailscale_mode` | `serve` | Use Tailscale Serve for secure HTTPS access |

### Why Loopback Binding?

Binding to loopback (127.0.0.1) ensures the gateway is never directly accessible from the network, even if firewall rules are misconfigured. Access is only possible via:

1. **SSH tunnel** (port forwarding)
2. **Tailscale Serve** (recommended - provides HTTPS)

## Tailscale Access

Clawdbot's gateway (port {{ clawdbot_gateway_port | default(18789) }}) is bound to localhost. Access it via:

1. **SSH tunnel**:
   ```bash
   ssh -L 18789:localhost:18789 user@server
   # Then browse to http://localhost:18789
   ```

2. **Tailscale Serve** (recommended):
   ```bash
   # Expose via Tailscale Serve (HTTPS)
   tailscale serve https / http://localhost:18789
   
   # Access from any device on your Tailnet:
   # https://your-machine-name.your-tailnet.ts.net/
   ```

## Network Flow

```
Internet → UFW (SSH only) → DOCKER-USER Chain → DROP (unless localhost/established)
Container → NAT → Internet (outbound allowed)
```
