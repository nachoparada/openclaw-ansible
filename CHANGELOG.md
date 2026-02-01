# Changelog 

## [Unreleased]

### 🔧 Improvements

#### Installer and Docs
- **Align install URLs**: Use `nachoparada/openclaw-ansible` consistently in `install.sh`
- **Clarify install methods**: Recommend clone-and-run for variable overrides, keep one-liner for defaults only
- **Move Ansible install**: `run-playbook.sh` now installs Ansible when missing, keeping installer logic in one place
- **Move collection install**: `run-playbook.sh` now installs Ansible collections before running the playbook

#### Node.js Installation
- **Use native Ansible modules**: Replaced shell-based GPG key and repo setup with `get_url` and `apt_repository` modules for better idempotency and change detection
- **Conditional apt cache update**: Only update apt cache when the NodeSource repository is newly added
- **Use `community.general.npm` module**: Replaced command-based pnpm installation with the npm module for better idempotency

#### Docker Installation (Linux)
- **Use native Ansible modules**: Replaced shell-based GPG key and repo setup with `get_url` and `apt_repository` modules for better idempotency and change detection
- **Conditional apt cache update**: Only update apt cache when the Docker repository is newly added
- **Architecture mapping**: Added `aarch64` to `arm64` mapping for ARM64 support

#### Tailscale Installation (Linux)
- **Use native Ansible modules**: Replaced shell-based GPG key and repo setup with `get_url` and `apt_repository` modules for better idempotency and change detection
- **Improved connection detection**: Parse `tailscale status --json` output to check `BackendState` instead of relying on exit codes
- **Conditional apt cache update**: Only update apt cache when the Tailscale repository is newly added

## [0.5.0] - 2026-02-01

### 🚀 Initial OpenClaw Release

This version represents the first release of the **OpenClaw Ansible** project, a continuation and rebranding of the original **ClawdBot Ansible** repository. 

*Note: Versioning has been reset to 0.5.0 for this new project phase.*

*Credit: This project is a continuation and rebranding of the [ClawdBot Ansible](https://github.com/clawdbot/clawdbot-ansible) repository. We thank the original contributors for their work on the initial automation framework.*

### ✨ New Features

#### Tailscale Integration
- **Auto-connect with authkey**: Automatically connect to Tailscale using an auth key
- **SSH flag support**: Enable Tailscale SSH during connection
- **Tailnet access**: Gateway configuration for Tailnet access

#### Gateway Enhancements
- **Auto-generate auth token**: Gateway auth token is automatically generated if not set
- **Auto-start daemon option**: Option to automatically start the gateway daemon after installation
- **Configurable allowed networks**: Firewall rules for gateway access can be configured per network

#### Security Improvements
- **SSH hardening for Linux**: Added SSH security hardening configuration
- **Timezone configuration**: Configurable system timezone

#### Configuration Options
- **PATH configuration variables**: Added variables to configure PATH for the openclaw user

### 🐛 Bug Fixes

- **Playbook**: Use `combine` filter for `ansible_env` to preserve existing environment variables
- **Playbook**: Add `become: false` to Homebrew installation task
- **Playbook**: Install `acl` package for privilege escalation on Linux
- **User**: Use `ansible.posix.authorized_key` module for SSH key management
- **Lint**: Resolved ansible-lint errors

### 🔧 Refactoring & Build

- **Rebranding**: Complete rebrand from ClawdBot to OpenClaw (commands, paths, variables, docs)
- **Task order**: Move user creation to run first in task order
- **Ansible version**: Update minimum Ansible version to 9.x and pin CI versions

### 📚 Documentation

- All docs reference OpenClaw and new CLI commands
- URLs updated to `docs.openclaw.ai`
- GitHub URLs updated to `github.com/nachoparada/openclaw-ansible`
- Lint badge updated to use `nachoparada/openclaw-ansible`

### Files Renamed
- `roles/clawdbot/` → `roles/openclaw/`
- `tasks/clawdbot.yml` → `tasks/openclaw.yml`
- `tasks/clawdbot-release.yml` → `tasks/openclaw-release.yml`
- `tasks/clawdbot-development.yml` → `tasks/openclaw-development.yml`
- `templates/clawdbot-host.service.j2` → `templates/openclaw-gateway.service.j2`
- `templates/clawdbot-config.yml.j2` → `templates/openclaw-config.yml.j2`
- `files/clawdbot-setup.sh` → `files/openclaw-setup.sh`

### Variables Renamed
All `clawdbot_*` variables renamed to `openclaw_*`:
- `clawdbot_user` → `openclaw_user`
- `clawdbot_home` → `openclaw_home`
- `clawdbot_config_dir` → `openclaw_config_dir`
- `clawdbot_install_mode` → `openclaw_install_mode`
- `clawdbot_repo_url` → `openclaw_repo_url`

---

## [2.0.0] - 2025-01-09 (Historical - ClawdBot)

### 🎉 Major Changes

#### Multi-OS Support
- **Added macOS support** alongside Debian/Ubuntu
- **Homebrew installation** for both Linux and macOS
- **OS-specific task files** for clean separation
- **Automatic OS detection** with proper fallback

#### Installation Modes
- **Release Mode** (default): Install via `pnpm install -g clawdbot@latest`
- **Development Mode**: Clone repo, build from source, symlink binary
- Switch modes with `-e clawdbot_install_mode=development`
- Development aliases: `clawdbot-rebuild`, `clawdbot-dev`, `clawdbot-pull`

#### System Improvements
- **apt update & upgrade** runs automatically at start (Debian/Ubuntu)
- **Homebrew integrated** in PATH for all users
- **pnpm package manager** used for Clawdbot installation

### 🐛 Bug Fixes

#### Critical Fixes from User Feedback
1. **DBus Session Bus Issues** ✅
   - Fixed: `loginctl enable-linger` now configured automatically
   - Fixed: `XDG_RUNTIME_DIR` set in .bashrc
   - Fixed: `DBUS_SESSION_BUS_ADDRESS` configured properly
   - **No more manual** `eval $(dbus-launch --sh-syntax)` needed!

2. **User Switching Command** ✅
   - Fixed: Changed from `sudo -i -u clawdbot` to `sudo su - clawdbot`
   - Ensures proper login shell with .bashrc loading
   - Alternative documented: `sudo -u clawdbot -i`

3. **Clawdbot Installation** ✅
   - Changed: `pnpm add -g` → `pnpm install -g clawdbot@latest`
   - Added installation verification
   - Added version display

4. **Configuration Management** ✅
   - Removed automatic config.yml creation
   - Removed automatic systemd service installation
   - Let `clawdbot onboard --install-daemon` handle setup
   - Only create directory structure

### 📦 New Files Created

#### OS-Specific Task Files
```
roles/clawdbot/tasks/
├── system-tools-linux.yml      # apt-based tool installation
├── system-tools-macos.yml      # brew-based tool installation
├── docker-linux.yml            # Docker CE installation
├── docker-macos.yml            # Docker Desktop installation
├── firewall-linux.yml          # UFW configuration
├── firewall-macos.yml          # Application Firewall config
├── clawdbot-release.yml        # Release mode installation
└── clawdbot-development.yml    # Development mode installation
```

#### Documentation
- `UPGRADE_NOTES.md` - Detailed upgrade information
- `CHANGELOG.md` - This file
- `docs/development-mode.md` - Development mode guide

### 🔧 Modified Files

#### Core Playbook & Scripts
- **playbook.yml**
  - Added OS detection (is_macos, is_debian, is_linux, is_redhat)
  - Added apt update/upgrade at start
  - Added Homebrew installation
  - Enhanced welcome message with `clawdbot onboard --install-daemon`
  - Removed automatic config.yml creation
  
- **install.sh**
  - Added macOS detection
  - Removed Debian-only restriction
  - Better error messages for unsupported OS

- **run-playbook.sh**
  - Fixed user switch command documentation
  - Added alternative command options
  - Enhanced post-install instructions

- **README.md**
  - Updated for multi-OS support
  - Added OS-specific requirements
  - Updated quick-start with `clawdbot onboard --install-daemon`
  - Added Homebrew to feature list

#### Role Files
- **roles/clawdbot/defaults/main.yml**
  - Added OS-specific variables (homebrew_prefix, package_manager)
  
- **roles/clawdbot/tasks/main.yml**
  - No changes (orchestrator)

- **roles/clawdbot/tasks/system-tools.yml**
  - Refactored to delegate to OS-specific files
  - Added fail-safe for unsupported OS

- **roles/clawdbot/tasks/docker.yml**
  - Refactored to delegate to OS-specific files

- **roles/clawdbot/tasks/firewall.yml**
  - Refactored to delegate to OS-specific files

- **roles/clawdbot/tasks/user.yml**
  - Added loginctl enable-linger
  - Added XDG_RUNTIME_DIR configuration
  - Added DBUS_SESSION_BUS_ADDRESS setup
  - Fixed systemd user service support

- **roles/clawdbot/tasks/clawdbot.yml**
  - Changed to `pnpm install -g clawdbot@latest`
  - Added installation verification
  - Removed config.yml template generation
  - Removed systemd service installation
  - Only creates directory structure

- **roles/clawdbot/templates/clawdbot-host.service.j2**
  - Added XDG_RUNTIME_DIR environment
  - Added DBUS_SESSION_BUS_ADDRESS
  - Added Homebrew to PATH
  - Enhanced security settings (ProtectSystem, ProtectHome)

### 🚀 Workflow Changes

#### Old Workflow
```bash
# Installation
curl -fsSL https://.../install.sh | bash
sudo -i -u clawdbot              # ❌ Wrong command
nano ~/.clawdbot/config.yml      # Manual config
clawdbot login                   # Manual setup
# Missing DBus setup              # ❌ Errors
```

#### New Workflow - Release Mode (Default)
```bash
# Installation
curl -fsSL https://.../install.sh | bash
sudo su - clawdbot               # ✅ Correct command
clawdbot onboard --install-daemon # ✅ One command setup!
# DBus auto-configured             # ✅ Works
# Service auto-installed           # ✅ Works
```

#### New Workflow - Development Mode
```bash
# Installation with development mode
git clone https://github.com/pasogott/clawdbot-ansible.git
cd clawdbot-ansible
./run-playbook.sh -e clawdbot_install_mode=development

# Switch to clawdbot user
sudo su - clawdbot

# Make changes
clawdbot-dev              # cd ~/code/clawdbot
vim src/some-file.ts      # Edit code
clawdbot-rebuild          # pnpm build

# Test immediately
clawdbot doctor           # Uses new build
```

### 🎯 User Experience Improvements

#### Welcome Message
- Shows environment status (XDG_RUNTIME_DIR, DBUS, Homebrew, Clawdbot version)
- Recommends `clawdbot onboard --install-daemon` as primary command
- Provides manual setup steps as alternative
- Lists useful commands for troubleshooting

#### Environment Configuration
- Homebrew automatically added to PATH
- pnpm global bin directory configured
- DBus session bus properly initialized
- XDG_RUNTIME_DIR set for systemd user services

#### Directory Structure
Ansible creates only structure, no config files:
```
~/.clawdbot/
├── sessions/       # Created (empty)
├── credentials/    # Created (secure: 0700)
├── data/          # Created (empty)
└── logs/          # Created (empty)
# clawdbot.json    # NOT created - user's clawdbot creates it
# config.yml       # NOT created - deprecated
```

### 🔒 Security Enhancements

#### Systemd Service Hardening
- `ProtectSystem=strict` - System directories read-only
- `ProtectHome=read-only` - Limited home access
- `ReadWritePaths=~/.clawdbot` - Only config writable
- `NoNewPrivileges=true` - No privilege escalation

#### User Isolation
- Dedicated clawdbot system user
- lingering enabled for systemd user services
- Proper DBus session isolation
- XDG_RUNTIME_DIR per-user

### 📊 Platform Support Matrix

| Feature | Debian/Ubuntu | macOS | Status |
|---------|--------------|-------|--------|
| Base Installation | ✅ | ✅ | Tested |
| Homebrew | ✅ | ✅ | Working |
| Docker | Docker CE | Docker Desktop | Working |
| Firewall | UFW | Application FW | Working |
| systemd | ✅ | ❌ | Linux only |
| DBus Setup | ✅ | N/A | Linux only |
| pnpm + Clawdbot | ✅ | ✅ | Working |

### ⚠️ Breaking Changes

1. **User Switch Command Changed**
   - Old: `sudo -i -u clawdbot`
   - New: `sudo su - clawdbot`
   - Impact: Update documentation, scripts

2. **No Auto-Configuration**
   - Old: config.yml auto-created
   - New: User runs `clawdbot onboard`
   - Impact: Users must run onboard command

3. **No Auto-Service Install**
   - Old: systemd service auto-installed
   - New: `clawdbot onboard --install-daemon`
   - Impact: Service not running after ansible

### 🔄 Migration Guide

#### For Fresh Installations
Just run the new installer - everything works out of the box!

#### For Existing Installations
```bash
# 1. Add environment variables
echo 'export XDG_RUNTIME_DIR=/run/user/$(id -u)' >> ~/.bashrc

# 2. Enable lingering
sudo loginctl enable-linger clawdbot

# 3. Add Homebrew (Linux)
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc

# 4. Reload
source ~/.bashrc

# 5. Reinstall clawdbot
pnpm install -g clawdbot@latest
```

### 📚 Documentation Updates

- README.md: Multi-OS support documented
- UPGRADE_NOTES.md: Detailed technical changes
- CHANGES.md: User-facing changelog (this file)
- install.sh: Updated help text
- run-playbook.sh: Better instructions

### 🐛 Known Issues

#### macOS Limitations
- systemd not available (Linux feature)
- Some Linux-specific tools not installed
- Firewall configuration limited
- **Recommendation**: Use for development, not production

#### Future Enhancements
- [ ] launchd support for macOS service management
- [ ] Full pf firewall configuration for macOS
- [ ] macOS-specific user management
- [ ] Cross-platform testing suite

### 🙏 Credits

Based on user feedback and real-world usage patterns from the clawdbot community.

Special thanks to early testers who identified the DBus and user switching issues!

---

**For detailed technical information**, see `UPGRADE_NOTES.md`

**For installation instructions**, see `README.md`
