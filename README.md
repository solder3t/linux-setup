# 🐧 Linux-Setup

> **One-command development environment bootstrap** for Arch, Fedora and Ubuntu/Debian. ***I made this For Personal Use.***

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/solder3t/linux-setup/pulls)

---

## ✅ Supported Distributions

| Distribution | Package Manager | Tested |
|---|---|---|
| **Arch Linux** | `pacman` + AUR (`yay`/`paru`) | ✅ Arch|
| **Fedora** | `dnf` | ✅ Fedora 43|
| **Ubuntu / Debian** | `apt-get` / `nala` | ✅ 22.04 / 24.04 / 25.10|

> Privilege escalation automatically detects `sudo`.

## ✨ Features

- 🔮 **Interactive TUI** — Search, filter, and preview plugin scripts before installing using a rich `fzf`-based interface with checkbox status and live source preview.
- 🧩 **Plugin Architecture** — 48 self-contained plugins across 12 categories
- 🔍 **Smart Detection** — Auto-detects distro, architecture, package manager, escalation tool, init system
- 🏗️ **Chaotic AUR** — One-click setup for Arch-based distros
- 📦 Complete Android **ROM + kernel** build dependencies
- ⚙️ **Java 21**, Clang/LLVM/LLD, GNU cross-compilers
- 🧠 Google's official **repo** tool
- 🚀 **AOSP clang prebuilts**
- ⚡ **ccache preconfigured (50 GB)**
- 🔧 **ulimit tuning** for Soong & Ninja
- 🔌 **adb / fastboot + udev rules**
- 🐚 **ZSH + Oh-My-Zsh + Powerlevel10k + fastfetch**
- 🚀 **Modern CLI Tools**:
  - **Editors**: Neovim
  - **Terminals**: Ghostty (w/ Config), Alacritty (w/ Config), Kitty (w/ Config)
  - **Utils**: fzf, ripgrep, bat, zoxide, tldr, btop/htop, tmux
  - **Productivity**: lazygit, delta, fd, ncdu, jq, eza, yazi, direnv, duf
- 🔁 **Idempotent & resumable** (safe to re-run anytime)

## 🚀 Quick Start

### One-liner (Interactive)

```bash
curl -fsSL https://solder3t.github.io/linsetup | bash
```

### Manual Install & CLI Options

```bash
git clone https://github.com/solder3t/linux-setup.git
cd linux-setup
chmod +x install.sh

# Interactive TUI mode (fuzzy search, preview code with fzf)
./install.sh

# Direct installation (headless mode)
./install.sh install android zsh

# List all available plugins, description, and host compatibility in a neat table
./install.sh list

# Automated config-driven setup using a JSON file:
./install.sh -y -c my_config.json

# Uninstall specific plugins
./install.sh uninstall chrome floop
```

### JSON Configuration Format

You can automate installations by creating a `config.json` file:

```json
{
  "auto_execute": [
    "zsh",
    "fastfetch",
    "neovim"
  ],
  "skip_confirmation": true
}
```


## 🏗️ Architecture

```
linux-setup/
├── install.sh           # Entry point (bootstrap + CLI)
├── lib/
│   ├── detect.sh        # Environment detection (distro, PM, arch, escalation)
│   ├── state.sh         # Idempotent state management
│   ├── packages.sh      # Package name mappings per PM
│   ├── installers.sh    # Shared install utilities
│   ├── plugin.sh        # Plugin loader & runner (with timing)
│   └── ui.sh            # TUI (banner + whiptail selector)
├── plugins/
│   ├── android/         # ROM/kernel build deps (core, build, libs, java, python, tools)
│   ├── bash/            # Bash config + Starship
│   ├── zsh/             # Zsh + OMZ + P10k
│   ├── ccache/          # CCache + ulimits
│   ├── clang/           # AOSP Clang prebuilts
│   ├── tools/           # 25+ CLI tools (bat, fzf, ripgrep, lazygit, chaotic-aur, ...)
│   ├── editors/         # Neovim
│   ├── terminals/       # Alacritty, Kitty (with configs)
│   ├── browsers/        # Chrome, Floorp
│   ├── fonts/           # MesloLGS Nerd Font
│   ├── ide/             # VS Code, Android Studio, Antigravity
│   └── bootloader/      # GRUB themes
├── bash/                # Bash dotfiles & Starship config
└── zsh/                 # Zsh dotfiles & P10k config
```

Each plugin is a self-contained `plugin.sh` with `plugin_describe()` and `plugin_install()` hooks.

## 🔌 Writing a Plugin

Create `plugins/<category>/<name>/plugin.sh`:

```bash
plugin_describe() { echo "my-tool - Description of my tool"; }

plugin_install() {
  if command_exists my-tool; then
    echo "✅ my-tool is already installed"
    return
  fi

  echo "📦 Installing my-tool..."
  case "$PM" in
    pacman)       $ESCALATION_TOOL $PM -S --needed --noconfirm my-tool ;;
    dnf)          $ESCALATION_TOOL dnf install -y my-tool ;;
    apt-get|nala) $ESCALATION_TOOL apt-get install -y my-tool ;;
    zypper)       $ESCALATION_TOOL zypper --non-interactive install my-tool ;;
    apk)          $ESCALATION_TOOL apk add my-tool ;;
    xbps-install) $ESCALATION_TOOL xbps-install -Sy my-tool ;;
  esac
}
```

**Available globals**: `$PM`, `$ESCALATION_TOOL`, `$AUR_HELPER`, `$DISTRO_ID`, `$ARCH`, `$ROOT_DIR`, `$INIT_MANAGER`

## 🙏 Acknowledgments

This project's environment detection, privilege escalation, package manager abstraction patterns, fzf-based sidebar preview concept, and system setup scripts are inspired by and adapted from:

- **[ChrisTitusTech/linutil](https://github.com/ChrisTitusTech/linutil)** — Chris Titus Tech's Linux Toolbox (MIT License)
  - Distro, privilege escalation, package manager, and architecture detection patterns.
  - Interactive TUI concept with sidebar description and source code preview.
  - Core scripts in the `System Setup` category, including CachyOS Repos, DNF Tuning, RPM Fusion setup, Multimedia Codecs, SSD TRIM timer, Snapd removal, Timeshift backup interface, Samba/SSH server setups, and overall system cleanup.
  - AUR helper auto-installation logic.

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.
