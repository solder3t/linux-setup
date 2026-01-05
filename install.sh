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
  exec bash ./install.sh "$@" < /dev/tty
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$ROOT_DIR/lib/state.sh"
source "$ROOT_DIR/lib/detect.sh"
source "$ROOT_DIR/lib/plugin.sh"
[[ -f "$ROOT_DIR/lib/installers.sh" ]] && source "$ROOT_DIR/lib/installers.sh"
[[ -f "$ROOT_DIR/lib/ui.sh" ]] && source "$ROOT_DIR/lib/ui.sh"

load_plugins

CMD="${1:-install}"
shift || true

case "$CMD" in
  install)
    if [[ $# -gt 0 ]]; then
      run_selected_plugins install "$@"
    else
      # Check if interactive terminal
      if [[ -t 0 && -t 1 && -n "${DISPLAY:-}" ]]; then
         # Only run UI if we have a display term (heuristic)
         # Actually just -t 0 (stdin is TTY) should be enough for whiptail
         if command -v whiptail >/dev/null; then
            echo "🔮 Interactive mode detected"
            SELECTED_PLUGINS=$(ui_select_plugins) || exit 0
            if [[ -n "$SELECTED_PLUGINS" ]]; then
                # Convert space-delimited string to array
                read -ra TARGETS <<< "$SELECTED_PLUGINS"
                run_selected_plugins install "${TARGETS[@]}"
            else
                echo "⚠️ No plugins selected."
            fi
            exit 0
         fi
      fi
      
      run_default_profile
    fi
    ;;
  uninstall)
    run_selected_plugins uninstall "$@"
    ;;
  plugins)
    echo "Available plugins:"
    run_plugin_hook describe
    ;;
  *)
    echo "Usage: linux-setup [install|uninstall|plugins]"
    ;;
esac

