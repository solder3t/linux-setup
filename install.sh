#!/usr/bin/env bash
set -euo pipefail

[[ $EUID -eq 0 ]] && { echo "Do not run as root"; exit 1; }

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="$HOME/.setup-state"
mkdir -p "$STATE_DIR"

source "$ROOT_DIR/lib/state.sh"
source "$ROOT_DIR/lib/detect.sh"
source "$ROOT_DIR/lib/packages.sh"
source "$ROOT_DIR/lib/installers.sh"

echo "=================================================="
echo " Android ROM & Kernel Build Environment Setup"
echo "=================================================="

detect_distro
arch_pre_setup
install_android_build_deps
ubuntu_ncurses_compat
install_android_udev
install_repo_tool
install_clang_prebuilts
configure_git_lfs
configure_ccache
configure_ulimits
install_zsh_stack

echo "Setup complete. Re-login or reboot recommended."
