---
title: Architecture
description: Technical implementation details
---

# Architecture

## Component Overview

```
┌─────────────────────────────────────────┐
│ UFW Firewall (SSH only)                 │
└──────────────┬──────────────────────────┘
               │
┌──────────────┴──────────────────────────┐
│ DOCKER-USER Chain (iptables)            │
│ Blocks all external container access    │
└──────────────┬──────────────────────────┘
               │
┌──────────────┴──────────────────────────┐
│ Docker Daemon                            │
│ - Non-root containers                    │
│ - Localhost-only binding                 │
└──────────────┬──────────────────────────┘
               │
┌──────────────┴──────────────────────────┐
│ OpenClaw Container                       │
│ User: openclaw                           │
│ Port: 127.0.0.1:18789                    │
└──────────────────────────────────────────┘
```

## File Structure

```
/home/openclaw/.openclaw/
├── openclaw.json
├── sessions/
├── credentials/
└── workspace/

/etc/systemd/system/
└── openclaw-gateway.service

/etc/docker/
└── daemon.json

/etc/ufw/
└── after.rules (DOCKER-USER chain)
```

## Service Management

OpenClaw runs as a systemd user service:

```bash
# Systemd controls the gateway
systemd --user → openclaw gateway
```

## Installation Flow

1. **Tailscale Setup** (`tailscale.yml`)
   - Add Tailscale repository
   - Install Tailscale package
   - Display connection instructions

2. **User Creation** (`user.yml`)
   - Create `openclaw` system user

3. **Docker Installation** (`docker.yml`)
   - Install Docker CE + Compose V2
   - Add user to docker group
   - Create `/etc/docker` directory

4. **Firewall Setup** (`firewall.yml`)
   - Install UFW
   - Configure DOCKER-USER chain
   - Configure Docker daemon (`/etc/docker/daemon.json`)
   - Allow SSH (22/tcp) and Tailscale (41641/udp)

5. **Node.js Installation** (`nodejs.yml`)
   - Add NodeSource repository
   - Install Node.js 22.x
   - Install pnpm globally

6. **OpenClaw Setup** (`openclaw.yml`)
   - Create directories
   - Install OpenClaw (release or development mode)
   - Seed gateway configuration
   - Install and start gateway service

## Key Design Decisions

### Why UFW + DOCKER-USER?

Docker manipulates iptables directly, bypassing UFW. The DOCKER-USER chain is evaluated before Docker's FORWARD chain, allowing us to block traffic before Docker sees it.

### Why Localhost Binding?

Defense in depth. Even if DOCKER-USER fails, localhost binding prevents external access.

### Why Systemd Service?

- Auto-start on boot
- Clean lifecycle management
- Integration with system logs
- Dependency management (after Docker)

### Why Non-Root Container?

Principle of least privilege. If container is compromised, attacker has limited privileges.

## Ansible Task Order

```
main.yml
├── user.yml (create openclaw user)
├── system-tools.yml (install tools)
├── tailscale.yml (VPN setup)
├── docker.yml (install Docker, create /etc/docker)
├── firewall.yml (configure UFW + Docker daemon)
├── nodejs.yml (Node.js + pnpm)
├── openclaw.yml (gateway setup)
└── ssh-hardening.yml (SSH security)
```

Order matters: Docker must be installed before firewall configuration because:
1. `/etc/docker` directory must exist for `daemon.json`
2. Docker service must exist to be restarted after config changes
