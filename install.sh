#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/solder3t/linux-setup"
REPO_BRANCH="main"
REPO_NAME="linux-setup"

if [[ -z "${BASH_SOURCE[0]:-}" || ! -f "${BASH_SOURCE[0]}" ]]; then
  echo "📦 Running via one-liner, bootstrapping repository..."
  WORKDIR="$(mktemp -d)"
  cd "$WORKDIR"
  curl -fsSL "$REPO_URL/archive/refs/heads/$REPO_BRANCH.tar.gz" | tar -xz
  cd "$REPO_NAME-$REPO_BRANCH"
  exec bash ./install.sh "$@"
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$ROOT_DIR/lib/state.sh"
source "$ROOT_DIR/lib/plugin.sh"
[[ -f "$ROOT_DIR/lib/installers.sh" ]] && source "$ROOT_DIR/lib/installers.sh"
[[ -f "$ROOT_DIR/lib/detect.sh" ]] && source "$ROOT_DIR/lib/detect.sh"

load_plugins

CMD="${1:-install}"
shift || true

case "$CMD" in
  install)   run_plugin_hook install ;;
  uninstall) run_plugin_hook uninstall ;;
  plugins)   echo "Available plugins:"; run_plugin_hook describe ;;
  *) echo "Usage: linux-setup [install|uninstall|plugins]" ;;
esac
