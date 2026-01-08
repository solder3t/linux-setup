## ✅ Supported Distributions

- **Arch Linux**
- **Fedora**
- **Ubuntu / Debian-based** (Ubuntu 22.04 / 24.04 tested)

## ✨ Features

- 🔮 **Interactive TUI**: Select exactly what you want to install
- 📦 Complete Android **ROM + kernel** build dependencies
- ⚙️ **Java 21**, Clang/LLVM/LLD, GNU cross-compilers
- 🧠 Google’s official **repo** tool
- 🚀 **AOSP clang prebuilts**
- ⚡ **ccache preconfigured (50 GB)**
- 🔧 **ulimit tuning** for Soong & Ninja
- 🔌 **adb / fastboot + udev rules**
- 🐚 **ZSH + Oh-My-Zsh + Powerlevel10k + fastfetch**
- 🚀 **Modern CLI Tools**:
  - **Editors**: Neovim
  - **Terminals**: Alacritty (w/ Config), Kitty (w/ Config)
  - **Utils**: fzf, ripgrep, bat, zoxide, tldr, btop/htop, tmux
  - **Productivity**: lazygit, delta, fd, ncdu, jq, eza, yazi, direnv, duf
- 🔁 **Idempotent & resumable** (safe to re-run anytime)

## 🚀 Quick Start

### One-liner (Interactive)
Run this command to start the interactive installer:
```bash
curl -fsSL https://raw.githubusercontent.com/solder3t/linux_setup/main/install.sh | bash
```

### Manual Install
```bash
git clone https://github.com/solder3t/linux_setup.git
cd linux_setup
chmod +x install.sh
./install.sh           # Interactive mode
./install.sh android   # Headless mode (install specific plugins)
```
