#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/solder3t/linux-setup"
REPO_BRANCH="main"
REPO_NAME="linux-setup"

# ── Bootstrap (one-liner support) ───────────────────────────────
if [[ -z "${BASH_SOURCE[0]:-}" || ! -f "${BASH_SOURCE[0]}" ]]; then
  echo "📦 Running via one-liner, bootstrapping repository..."
  WORKDIR="$(mktemp -d)"
  cd "$WORKDIR"
  curl -fsSL "$REPO_URL/archive/refs/heads/$REPO_BRANCH.tar.gz" | tar -xz
  cd "$REPO_NAME-$REPO_BRANCH"
  exec bash ./install.sh "$@" < /dev/tty
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Source Libraries ────────────────────────────────────────────
source "$ROOT_DIR/lib/state.sh"
source "$ROOT_DIR/lib/detect.sh"       # detect_env runs on source
source "$ROOT_DIR/lib/packages.sh"
source "$ROOT_DIR/lib/plugin.sh"
[[ -f "$ROOT_DIR/lib/installers.sh" ]] && source "$ROOT_DIR/lib/installers.sh"
[[ -f "$ROOT_DIR/lib/ui.sh" ]] && source "$ROOT_DIR/lib/ui.sh"

# ── Load Plugins ────────────────────────────────────────────────
load_plugins

# ── Parse Command ───────────────────────────────────────────────
CMD="${1:-install}"
shift || true

case "$CMD" in
  --help|-h)
    cat <<EOF
Usage: linux-setup [COMMAND] [PLUGINS...]

Commands:
  install [PLUGINS...]   Install plugins (interactive if no args, TTY detected)
  uninstall PLUGINS...   Uninstall specified plugins
  plugins                List all available plugins
  --version              Show version
  --help                 Show this help

Examples:
  ./install.sh                       # Interactive TUI
  ./install.sh install android zsh   # Install specific plugins
  ./install.sh plugins               # List all plugins

Project: $REPO_URL
EOF
    exit 0
    ;;
  --version|-v)
    echo "linux-setup ${VERSION:-2.0.0}"
    exit 0
    ;;
  install)
    if [[ $# -gt 0 ]]; then
      # Headless mode — print banner then install
      [[ -t 1 ]] && print_banner
      run_selected_plugins install "$@"
    elif [[ -t 0 && -t 1 ]]; then
         # Ensure whiptail is available
         if ! command_exists whiptail; then
             printf "%b\n" "${YELLOW}⚠ Installing whiptail for interactive mode...${RC}"
             case "$PM" in
                 pacman)       $ESCALATION_TOOL $PM -S --needed --noconfirm libnewt ;;
                 dnf)          $ESCALATION_TOOL dnf install -y newt ;;
                 apt-get|nala) $ESCALATION_TOOL apt-get install -y whiptail ;;
                 zypper)       $ESCALATION_TOOL zypper --non-interactive install newt ;;
                 apk)          $ESCALATION_TOOL apk add newt ;;
                 xbps-install) $ESCALATION_TOOL xbps-install -Sy newt ;;
                 eopkg)        $ESCALATION_TOOL eopkg install -y newt ;;
             esac
         fi

         if ! command_exists whiptail; then
             printf "%b\n" "${RED}✖ whiptail not available. Running default profile.${RC}"
             run_default_profile
         else
             SELECTED_PLUGINS=$(ui_select_plugins) || exit 0
             if [[ -n "$SELECTED_PLUGINS" ]]; then
                 read -ra TARGETS <<< "$SELECTED_PLUGINS"
                 print_banner
                 run_selected_plugins install "${TARGETS[@]}"
             else
                 printf "%b\n" "${YELLOW}⚠ No plugins selected.${RC}"
             fi
         fi
    else
      run_default_profile
    fi

    if [[ ${#INSTALLED_SUMMARY[@]} -gt 0 ]]; then
        echo
        printf "%b\n" "${GREEN}${BOLD}✅ Installation Complete!${RC}"
        printf "%b\n" "   Installed plugins:"
        for p in "${INSTALLED_SUMMARY[@]}"; do
            printf "%b\n" "   ${GREEN}✔${RC} $p"
        done
        echo
        printf "%b\n" "${DIM}ℹ  You may need to log out and back in for some changes to take effect.${RC}"

        # Cleanup state directory
        state_cleanup
    fi
    ;;
  uninstall)
    run_selected_plugins uninstall "$@"
    ;;
  plugins)
    printf "%b\n" "${BOLD}Available plugins:${RC}"
    run_plugin_hook describe
    ;;
  *)
    echo "Usage: linux-setup [install|uninstall|plugins|--help|--version]"
    ;;
esac
