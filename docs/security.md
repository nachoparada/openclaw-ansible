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

1. Configured your SSH keys in the `openclaw_ssh_keys` variable
2. Tested SSH key access to avoid being locked out

```yaml
# Example: Configure SSH keys before running
openclaw_ssh_keys:
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
  - "127.0.0.1:18789:18789"
```

## Layer 4: Non-Root Container

Container processes run as unprivileged `openclaw` user.

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

By default, the OpenClaw gateway is configured with secure defaults:

- **Loopback binding**: Gateway binds to 127.0.0.1, not accessible from network
- **Tailscale Serve**: Access gateway securely via Tailscale with HTTPS
- **Auto-generated token**: A random 64-character authentication token is generated if not provided

### Configuration Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `openclaw_gateway_bind` | `loopback` | Bind to 127.0.0.1 (secure) or 0.0.0.0 (network) |
| `openclaw_gateway_mode` | `local` | `local` for localhost only, `network` for network access |
| `openclaw_gateway_tailscale_mode` | `serve` | Use Tailscale Serve for secure HTTPS access |
| `openclaw_gateway_token` | auto-generated | 64-character authentication token |

### Gateway Authentication Token

The gateway requires an authentication token for API access. If you don't provide one via `openclaw_gateway_token`, a secure 64-character random token is automatically generated during installation.

The token is stored in `~/.openclaw/openclaw.json` with restricted permissions (mode 0600).

### Why Loopback Binding?

Binding to loopback (127.0.0.1) ensures the gateway is never directly accessible from the network, even if firewall rules are misconfigured. Access is only possible via:

1. **SSH tunnel** (port forwarding)
2. **Tailscale Serve** (recommended - provides HTTPS)

### Network-Based Access Control

If you need direct network access to the gateway (not recommended for public networks), you can configure `openclaw_allowed_networks` to allow specific IP ranges through the UFW firewall:

```yaml
# Example: Allow access from trusted networks
openclaw_allowed_networks:
  - { ip: "192.168.1.0/24", comment: "Home network" }
  - { ip: "10.100.0.0/16", comment: "Tailscale network" }
```

**Important**: Even with network access enabled, the gateway still requires the authentication token for API requests.

## Tailscale Access

OpenClaw's gateway (port 18789) is bound to localhost. Access it via:

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
