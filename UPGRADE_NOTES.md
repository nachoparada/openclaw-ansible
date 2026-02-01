# Upgrade Notes

## Version 0.5.0 - OpenClaw Transition

### Overview

Version 0.5.0 marks the transition of this project from **ClawdBot Ansible** to **OpenClaw Ansible**. While the core automation remains based on the excellent foundation provided by the original project, this version introduces full branding for [OpenClaw](https://openclaw.ai), updated CLI commands, and a new versioning scheme starting from 0.5.0.

*Credit: This project is a continuation and rebranding of the ClawdBot Ansible repository. We thank the original contributors for their work on the initial automation framework.*

### Key Changes

This release completes the rebrand. All commands, paths, variables, and documentation have been updated to the OpenClaw standard.

| Element | Old (ClawdBot) | New (OpenClaw) |
|---------|----------------|----------------|
| CLI Command | `clawdbot` | `openclaw` |
| Home Dir | `/home/clawdbot` | `/home/openclaw` |
| Config Dir | `~/.clawdbot/` | `~/.openclaw/` |
| Config File | `clawdbot.json` | `openclaw.json` |
| Gateway | `daemon` | `gateway` |
| Channels | `providers` | `channels` |
| URL | `docs.clawd.bot` | `docs.openclaw.ai` |

### Variable Migration

All Ansible variables have been renamed from `clawdbot_*` to `openclaw_*`. If you are using custom playbooks or inventory files, you must update your variables:

```yaml
# Old
clawdbot_user: clawdbot
clawdbot_install_mode: release

# New
openclaw_user: openclaw
openclaw_install_mode: release
```

### Migration from ClawdBot

If you are migrating from an existing ClawdBot installation, a fresh install is recommended to ensure all paths and permissions are correctly set up:

1. **Stop the old daemon**: `sudo su - clawdbot -c "clawdbot daemon stop"`
2. **Remove the old user**: `sudo userdel -r clawdbot`
3. **Run the OpenClaw installer**:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/nachoparada/openclaw-ansible/main/install.sh | bash
   ```
4. **Onboard**: `sudo su - openclaw -c "openclaw onboard --install-gateway"`

### Internal Structure Changes

- Role renamed from `roles/clawdbot` to `roles/openclaw`.
- All task files renamed from `clawdbot-*.yml` to `openclaw-*.yml`.
- Templates updated to use `openclaw` naming and variables.

---

# Historical Upgrade Notes (ClawdBot Era)

*The documentation below is preserved for historical context and technical reference regarding the original foundation of the automation framework.*

# Upgrade Notes - Option A Implementation

## ✅ Completed Changes

### 1. Installation Modes (Release vs Development)
- **File**: `roles/clawdbot/defaults/main.yml`
- Added `clawdbot_install_mode` variable (release | development)
- Release mode: Install via `pnpm install -g clawdbot@latest` (default)
- Development mode: Clone repo, build, symlink binary
- Development settings: repo URL, branch, code directory

**Files Created**:
- `roles/clawdbot/tasks/clawdbot-release.yml` - npm installation
- `roles/clawdbot/tasks/clawdbot-development.yml` - git clone + build
- `docs/development-mode.md` - comprehensive guide

**Development Mode Features**:
- Clones to `~/code/clawdbot`
- Runs `pnpm install` and `pnpm build`
- Symlinks `bin/clawdbot.js` to `~/.local/bin/clawdbot`
- Adds aliases: `clawdbot-rebuild`, `clawdbot-dev`, `clawdbot-pull`
- Sets `CLAWDBOT_DEV_DIR` environment variable

**Usage**:
```bash
# Release mode (default)
./run-playbook.sh

# Development mode
./run-playbook.sh -e clawdbot_install_mode=development

# With custom repo
ansible-playbook playbook.yml --ask-become-pass \
  -e clawdbot_install_mode=development \
  -e clawdbot_repo_url=https://github.com/YOUR_USERNAME/clawdbot.git \
  -e clawdbot_repo_branch=feature-branch
```

### 2. OS Detection & apt update/upgrade
- **File**: `playbook.yml`
- Added OS detection in pre_tasks (macOS, Debian/Ubuntu, RedHat)
- Added `apt update && apt upgrade` at the beginning (Debian/Ubuntu only)
- Detection variables: `is_macos`, `is_linux`, `is_debian`, `is_redhat`

### 2. Homebrew Installation
- **File**: `playbook.yml`
- Homebrew is now installed for both Linux and macOS
- Linux: `/home/linuxbrew/.linuxbrew/bin/brew`
- macOS: `/opt/homebrew/bin/brew`
- Automatically added to PATH

### 3. OS-Specific System Tools
- **Files**: 
  - `roles/clawdbot/tasks/system-tools.yml` (orchestrator)
  - `roles/clawdbot/tasks/system-tools-linux.yml` (apt-based)
  - `roles/clawdbot/tasks/system-tools-macos.yml` (brew-based)
- Tools installed via appropriate package manager per OS
- Homebrew shellenv integrated into .zshrc

### 4. OS-Specific Docker Installation
- **Files**:
  - `roles/clawdbot/tasks/docker.yml` (orchestrator)
  - `roles/clawdbot/tasks/docker-linux.yml` (Docker CE)
  - `roles/clawdbot/tasks/docker-macos.yml` (Docker Desktop)
- Linux: Docker CE via apt
- macOS: Docker Desktop via Homebrew Cask

### 5. OS-Specific Firewall Configuration
- **Files**:
  - `roles/clawdbot/tasks/firewall.yml` (orchestrator)
  - `roles/clawdbot/tasks/firewall-linux.yml` (UFW)
  - `roles/clawdbot/tasks/firewall-macos.yml` (Application Firewall)
- Linux: UFW with Docker isolation
- macOS: Application Firewall configuration

### 6. DBus & systemd User Service Fixes
- **File**: `roles/clawdbot/tasks/user.yml`
- Fixed: `loginctl enable-linger` for clawdbot user
- Fixed: XDG_RUNTIME_DIR set to `/run/user/$(id -u)`
- Fixed: DBUS_SESSION_BUS_ADDRESS configuration in .bashrc
- No more manual `eval $(dbus-launch --sh-syntax)` needed!

### 7. Systemd Service Template Enhancement
- **File**: `roles/clawdbot/templates/clawdbot-host.service.j2`
- Added XDG_RUNTIME_DIR environment variable
- Added DBUS_SESSION_BUS_ADDRESS
- Added Homebrew to PATH
- Enhanced security with ProtectSystem and ProtectHome

### 8. Clawdbot Installation via pnpm
- **File**: `roles/clawdbot/tasks/clawdbot.yml`
- Changed from `pnpm add -g` to `pnpm install -g clawdbot@latest`
- Added verification step
- Added version display

### 9. Correct User Switching Command
- **File**: `run-playbook.sh`
- Changed from `sudo -i -u clawdbot` to `sudo su - clawdbot`
- Alternative: `sudo -u clawdbot -i`
- Ensures proper login shell with .bashrc loaded

### 10. Enhanced Welcome Message
- **File**: `playbook.yml` (post_tasks)
- Recommends: `clawdbot onboard --install-daemon` as first command
- Shows environment status (XDG_RUNTIME_DIR, DBUS, Homebrew)
- Provides both quick-start and manual setup paths
- More helpful command examples

### 11. Multi-OS Install Script
- **File**: `install.sh`
- Removed Debian/Ubuntu-only check
- Added OS detection for macOS and Linux
- Proper messaging for detected OS

### 12. Updated Documentation
- **File**: `README.md`
- Multi-OS badge (Debian | Ubuntu | macOS)
- Updated features list
- Added OS-specific requirements
- Added post-install instructions with `clawdbot onboard --install-daemon`

## 🎯 Key Improvements

### Fixed Issues from User History
1. ✅ **DBus errors**: Automatically configured, no manual setup needed
2. ✅ **User switching**: Correct command (`sudo su - clawdbot`)
3. ✅ **Environment**: XDG_RUNTIME_DIR and DBUS properly set
4. ✅ **Homebrew**: Integrated and in PATH
5. ✅ **pnpm**: Uses `pnpm install -g clawdbot@latest`

### OS Detection Framework
- Clean separation between Linux and macOS tasks
- Easy to extend for other distros
- Fails gracefully with clear error messages

### Better User Experience
- Clear next steps after installation
- Recommends `clawdbot onboard --install-daemon`
- Helpful welcome message with environment status
- Proper shell initialization

## 🔄 Migration Path

### For Existing Installations
If you have an existing installation, you may need to:

```bash
# 1. Update environment variables
echo 'export XDG_RUNTIME_DIR=/run/user/$(id -u)' >> ~/.bashrc

# 2. Enable lingering
sudo loginctl enable-linger clawdbot

# 3. Add Homebrew to PATH (if using Linux)
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc

# 4. Reload shell
source ~/.bashrc

# 5. Reinstall clawdbot
pnpm install -g clawdbot@latest
```

## 📝 TODO - Future macOS Enhancements

### Items NOT Yet Implemented (for future)
- [ ] macOS-specific user creation (different from Linux)
- [ ] launchd service instead of systemd (macOS)
- [ ] Full pf firewall configuration (macOS)
- [ ] macOS-specific Tailscale configuration
- [ ] Testing on actual macOS hardware

### Current macOS Status
- ✅ Basic framework in place
- ✅ Homebrew installation works
- ✅ Docker Desktop installation configured
- ⚠️  Some tasks may need macOS testing/refinement

## 🧪 Testing Recommendations

### Linux (Debian/Ubuntu)
```bash
# Test OS detection
ansible-playbook playbook.yml --ask-become-pass --tags=never -vv

# Test full installation
./run-playbook.sh

# Verify clawdbot
sudo su - clawdbot
clawdbot --version
clawdbot onboard --install-daemon
```

### macOS (Future)
```bash
# Similar process, but may need refinements
# Recommend thorough testing before production use
```

## 🔒 Security Notes

### Enhanced systemd Security
- `ProtectSystem=strict`: Read-only system directories
- `ProtectHome=read-only`: Limited home access
- `ReadWritePaths`: Only ~/.clawdbot writable
- `NoNewPrivileges`: Prevents privilege escalation

### DBus Session Security
- User-specific DBus session
- Proper XDG_RUNTIME_DIR isolation
- No root access required for daemon

## 📚 Related Files

### Modified Files
- `playbook.yml` - Main orchestration with OS detection
- `install.sh` - Multi-OS detection
- `run-playbook.sh` - Correct user switch command
- `README.md` - Multi-OS documentation
- `roles/clawdbot/defaults/main.yml` - OS-specific variables
- `roles/clawdbot/tasks/*.yml` - OS-aware task orchestration
- `roles/clawdbot/templates/clawdbot-host.service.j2` - Enhanced service

### New Files Created
- `roles/clawdbot/tasks/system-tools-linux.yml`
- `roles/clawdbot/tasks/system-tools-macos.yml`
- `roles/clawdbot/tasks/docker-linux.yml`
- `roles/clawdbot/tasks/docker-macos.yml`
- `roles/clawdbot/tasks/firewall-linux.yml`
- `roles/clawdbot/tasks/firewall-macos.yml`
- `UPGRADE_NOTES.md` (this file)

---

**Implementation Date**: January 2025
**Implementation**: Option A (Incremental multi-OS support)
**Status**: ✅ Complete and ready for testing
