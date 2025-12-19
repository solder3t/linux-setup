## ✅ Supported Distributions

- **Arch Linux**
- **Fedora**
- **Ubuntu / Debian-based** (Ubuntu 22.04 / 24.04 tested)

---

## ✨ Features

- 📦 Complete Android **ROM + kernel** build dependencies
- ⚙️ **Java 21**, Clang/LLVM/LLD, GNU cross-compilers
- 🧠 Google’s official **repo** tool
- 🚀 **AOSP clang prebuilts**
- ⚡ **ccache preconfigured (50 GB)**
- 🔧 **ulimit tuning** for Soong & Ninja
- 🔌 **adb / fastboot + udev rules**
- 🐚 **ZSH + Oh-My-Zsh + Powerlevel10k + fastfetch**
- 🔁 **Idempotent & resumable** (safe to re-run anytime)

---

## 🚀 Quick Start

### Clone & run
```bash
git clone https://github.com/<your-username>/android-linux-setup.git
cd android-linux-setup
chmod +x install.sh
./install.sh

One-liner
curl -fsSL https://raw.githubusercontent.com/<your-username>/android-linux-setup/main/install.sh | bash
