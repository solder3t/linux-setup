#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/solder3t/linux_setup"
REPO_BRANCH="main"
REPO_NAME="linux_setup"

# --------------------------------------------------
# Detect curl | bash execution and bootstrap repo
# --------------------------------------------------
if [[ -z "${BASH_SOURCE[0]:-}" || ! -f "${BASH_SOURCE[0]}" ]]; then
  echo "📦 Running via one-liner, bootstrapping repository..."

  WORKDIR="$(mktemp -d)"
  cd "$WORKDIR"

  curl -fsSL "$REPO_URL/archive/refs/heads/$REPO_BRANCH.tar.gz" | tar -xz
  cd "$REPO_NAME-$REPO_BRANCH"

  exec bash ./install.sh
fi

# --------------------------------------------------
# Normal execution (cloned repo)
# --------------------------------------------------
[[ $EUID -eq 0 ]] && {
  echo "❌ Do not run as root"
  exit 1
}

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
install_optional_gcc_cross
ubuntu_ncurses_compat
install_android_udev
install_repo_tool
install_clang_prebuilts
configure_git_lfs
configure_ccache
configure_ulimits
install_zsh_stack

echo "Setup complete. Re-login or reboot recommended."
