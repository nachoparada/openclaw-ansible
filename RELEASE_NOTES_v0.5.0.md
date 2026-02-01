# Release v0.5.0 - Initial Release

## 🎉 First Public Release

OpenClaw Ansible provides automated deployment of [OpenClaw](https://openclaw.ai) on Linux and macOS systems.

### ✨ Features

#### Multi-OS Support
- **Linux** (Debian/Ubuntu) with full systemd integration
- **macOS** support with Homebrew
- Automatic OS detection with platform-specific tasks

#### Installation Modes
- **Release Mode** (default): Install from npm registry via `pnpm install -g openclaw@latest`
- **Development Mode**: Clone repo, build from source, symlink binary
- Switch modes with `-e openclaw_install_mode=development`

#### Gateway Service
- Systemd service for running OpenClaw as a background daemon
- Commands: `openclaw gateway install`, `openclaw gateway start`, `openclaw gateway stop`
- Auto-start on boot with proper user permissions
- **Auto-generate auth token**: Gateway auth token is automatically generated if not set
- **Auto-start daemon option**: Option to automatically start the gateway daemon after installation
- **Configurable allowed networks**: Firewall rules for gateway access can be configured per network
- **Tailnet access**: Gateway configuration for accessing via Tailscale network

#### Tailscale Integration
- **Auto-connect with authkey**: Automatically connect to Tailscale using an auth key
- **SSH flag support**: Enable Tailscale SSH during connection

#### Security
- **SSH hardening for Linux**: Added SSH security hardening configuration
- **Timezone configuration**: Configurable system timezone
- **PATH configuration variables**: Added variables to configure PATH for the openclaw user

#### Development Tooling
- Helper aliases: `openclaw-rebuild`, `openclaw-dev`, `openclaw-pull`
- Environment variable `OPENCLAW_DEV_DIR` for development path
- Automatic symlink management

#### System Configuration
- Homebrew package manager (Linux and macOS)
- Node.js via nvm with configurable version
- pnpm package manager
- Proper DBus session bus configuration
- XDG runtime directory setup
- User lingering enabled for systemd user services

### 🐛 Bug Fixes

- Use `combine` filter for `ansible_env` to preserve existing environment variables
- Add `become: false` to Homebrew installation task
- Install `acl` package for privilege escalation on Linux
- Use `ansible.posix.authorized_key` module for SSH key management
- Resolved ansible-lint errors

### 🔧 Build & Infrastructure

- Minimum Ansible version updated to 9.x
- CI versions pinned for stability

### 📦 Installation

#### Quick Start
```bash
curl -fsSL https://raw.githubusercontent.com/nachoparada/openclaw-ansible/main/install.sh | bash
```

#### Manual Installation
```bash
git clone https://github.com/nachoparada/openclaw-ansible.git
cd openclaw-ansible
./run-playbook.sh
```

#### Development Mode
```bash
./run-playbook.sh -e openclaw_install_mode=development
```

### 🔧 Post-Installation

After installation completes:

```bash
# Switch to openclaw user
sudo su - openclaw

# Run onboarding wizard
openclaw onboard

# Or with gateway auto-install
openclaw onboard --install-gateway
```

### 📚 Documentation

- [README.md](README.md) - Getting started
- [docs/installation.md](docs/installation.md) - Detailed installation guide
- [docs/configuration.md](docs/configuration.md) - Configuration options
- [docs/development-mode.md](docs/development-mode.md) - Development setup
- [docs/troubleshooting.md](docs/troubleshooting.md) - Common issues

### 📊 Testing

- ✅ yamllint: **PASSED**
- ✅ ansible-lint: **PASSED** (production profile)
- ✅ Tested on Debian 11/12
- ✅ Tested on Ubuntu 20.04/22.04/24.04
- ⚠️ macOS framework ready (needs real hardware testing)

### 🔗 Links

- **Documentation**: https://docs.openclaw.ai
- **Repository**: https://github.com/nachoparada/openclaw-ansible
- **OpenClaw**: https://openclaw.ai

---

**Full Changelog**: https://github.com/nachoparada/openclaw-ansible/blob/main/CHANGELOG.md
