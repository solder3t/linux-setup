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

# ── Preview Helper Function ─────────────────────────────────────

show_preview() {
  local target_name="$1"
  local plugin_path
  plugin_path=$(find_plugin_path "$target_name") || {
    echo "Error: Plugin '$target_name' not found."
    return 1
  }

  local p_dir c_dir dir_cat
  p_dir="$(dirname "$plugin_path")"
  c_dir="$(dirname "$p_dir")"
  dir_cat="$(basename "$c_dir")"
  [[ "$dir_cat" == "plugins" ]] && dir_cat="General"
  [[ "${dir_cat,,}" == "ide" ]] && dir_cat="IDE"
  [[ "$dir_cat" != "IDE" ]] && dir_cat="${dir_cat^}"
  local category
  category="$(get_category_display "$dir_cat")"

  local desc
  desc=$(get_plugin_description "$plugin_path" "$target_name")

  local status="Not Installed [ ]"
  if is_plugin_installed "$target_name" "$plugin_path"; then
    status="${GREEN}Installed [✔]${RC}"
  fi

  local compat="${GREEN}Supported on this system [✔]${RC}"
  if ! is_plugin_supported "$plugin_path"; then
    compat="${RED}Unsupported on this system [✖]${RC}"
  fi

  local width=70
  local line
  line=$(printf '═%.0s' $(seq 1 "$width"))

  printf "%b\n" "${CYAN}╔${line}╗${RC}"
  printf "%b\n" "${CYAN}║${RC}  ${BOLD}PLUGIN:${RC}       ${target_name}"
  printf "%b\n" "${CYAN}║${RC}  ${BOLD}CATEGORY:${RC}     ${category}"
  printf "%b\n" "${CYAN}║${RC}  ${BOLD}STATUS:${RC}       ${status}"
  printf "%b\n" "${CYAN}║${RC}  ${BOLD}COMPAT:${RC}       ${compat}"
  printf "%b\n" "${CYAN}╚${line}╝${RC}"
  echo
  printf "%b\n" "${YELLOW}${BOLD}DESCRIPTION:${RC}"
  printf "  %s\n" "$desc"
  echo
  printf "%b\n" "${YELLOW}${BOLD}SOURCE CODE (${plugin_path}):${RC}"
  
  if command_exists bat; then
    bat --language=bash --style=numbers,snip --color=always "$plugin_path"
  else
    cat "$plugin_path"
  fi
}

# ── Confirmation Helper Function ─────────────────────────────────

confirm_installation() {
  local targets=("$@")
  echo
  printf "%b\n" "${CYAN}${BOLD}📋 Plugins to be installed:${RC}"
  for target in "${targets[@]}"; do
    local plugin_path
    plugin_path=$(find_plugin_path "$target")
    local status="[pending]"
    if [[ -n "$plugin_path" ]] && is_plugin_installed "$target" "$plugin_path"; then
      status="${GREEN}[already installed]${RC}"
    fi
    printf "  %b•%b %-20s %b\n" "$CYAN" "$RC" "$target" "$status"
  done
  echo
  read -r -p "Proceed with installation? [Y/n] " yn
  case "$yn" in
    [nN]|[nN][oO]) return 1 ;;
    *) return 0 ;;
  esac
}

# ── CLI Options Parsing ──────────────────────────────────────────

SKIP_CONFIRMATION=false
CONFIG_FILE=""
SHOW_UNSUPPORTED=false
PREVIEW_PLUGIN=""
COMMAND=""
TARGETS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      cat <<HELP_EOF
Usage: linux-setup [OPTIONS] [COMMAND] [PLUGINS...]

Options:
  -h, --help               Show this help message and exit
  -v, --version            Show version info and exit
  -y, --skip-confirmation  Skip confirmation prompts before running tasks
  -c, --config <file>      Load plugin installations from a JSON or line-separated text config file
  --show-unsupported       Show unsupported plugins in the TUI menu
  --preview <plugin>       Internal: render details/source code preview for a plugin

Commands:
  install [PLUGINS...]     Install plugins (default command if omitted)
                           If no plugins are specified, starts the interactive TUI
  uninstall PLUGINS...     Uninstall specified plugins
  list, plugins            List all available plugins, descriptions, and compatibility

Examples:
  ./install.sh                       # Start interactive TUI
  ./install.sh install zsh neovim    # Headless install of zsh and neovim
  ./install.sh -y -c config.json     # Unattended install from configuration file
  ./install.sh list                  # List all plugins
HELP_EOF
      exit 0
      ;;
    -v|--version)
      echo "linux-setup ${VERSION:-2.0.0}"
      exit 0
      ;;
    -y|--skip-confirmation)
      SKIP_CONFIRMATION=true
      shift
      ;;
    -c|--config)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --config requires a file path." >&2
        exit 1
      fi
      CONFIG_FILE="$2"
      shift 2
      ;;
    --show-unsupported)
      SHOW_UNSUPPORTED=true
      export SHOW_UNSUPPORTED
      shift
      ;;
    --preview)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --preview requires a plugin name." >&2
        exit 1
      fi
      PREVIEW_PLUGIN="$2"
      shift 2
      ;;
    install|uninstall|list|plugins)
      COMMAND="$1"
      shift
      TARGETS=("$@")
      break
      ;;
    -*)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
    *)
      TARGETS=("$@")
      break
      ;;
  esac
done

# If no subcommand was set, default to "install"
if [[ -z "$COMMAND" ]]; then
  COMMAND="install"
fi

# ── Execute Internal Preview Mode ────────────────────────────────

if [[ -n "$PREVIEW_PLUGIN" ]]; then
  show_preview "$PREVIEW_PLUGIN"
  exit 0
fi

# ── Handle Configuration Loading ─────────────────────────────────

if [[ -n "$CONFIG_FILE" ]]; then
  if [[ ! -f "$CONFIG_FILE" ]]; then
    printf "%b\n" "${RED}✖ Config file not found: $CONFIG_FILE${RC}"
    exit 1
  fi

  printf "%b\n" "${CYAN}⚙ Loading configuration from: $CONFIG_FILE${RC}"
  
  if [[ "$CONFIG_FILE" == *.json ]]; then
    if ! command_exists python3; then
      printf "%b\n" "${RED}✖ Python 3 is required to parse JSON config files.${RC}"
      exit 1
    fi
    
    json_parsed=$(python3 -c "
import json, sys
try:
    with open('$CONFIG_FILE') as f:
        data = json.load(f)
    print('JSON_SKIP_CONFIRMATION=' + ('true' if data.get('skip_confirmation') else 'false'))
    print('JSON_TARGETS=(\"' + '\" \"'.join(data.get('auto_execute', [])) + '\")')
except Exception as e:
    print('ERROR: ' + str(e), file=sys.stderr)
    sys.exit(1)
" 2>&1)
    
    if [[ $? -ne 0 ]]; then
      printf "%b\n" "${RED}✖ Failed to parse JSON config:${RC}"
      echo "$json_parsed" >&2
      exit 1
    fi
    
    eval "$json_parsed"
    if [[ "$JSON_SKIP_CONFIRMATION" == "true" ]]; then
      SKIP_CONFIRMATION=true
    fi
    TARGETS+=("${JSON_TARGETS[@]}")
  else
    while IFS= read -r line || [[ -n "$line" ]]; do
      [[ "$line" =~ ^# ]] && continue
      [[ -z "${line//[[:space:]]/}" ]] && continue
      line=$(echo "$line" | xargs)
      TARGETS+=("$line")
    done < "$CONFIG_FILE"
  fi
fi

# ── Handle List/Plugins Command ──────────────────────────────────

if [[ "$COMMAND" == "list" || "$COMMAND" == "plugins" ]]; then
  printf "%b\n" "${BOLD}Available plugins:${RC}"
  printf "%-20s %-25s %-12s - %s\n" "Plugin" "Category" "Compatibility" "Description"
  line=$(printf '─%.0s' $(seq 1 80))
  printf "%b\n" "${DIM}${line}${RC}"
  
  for plugin in "${PLUGINS_LOADED[@]}"; do
    p_dir="$(dirname "$plugin")"
    p_name="$(basename "$p_dir")"
    c_dir="$(dirname "$p_dir")"
    dir_cat="$(basename "$c_dir")"

    [[ "$dir_cat" == "plugins" ]] && dir_cat="General"
    [[ "${dir_cat,,}" == "ide" ]] && dir_cat="IDE"
    [[ "$dir_cat" != "IDE" ]] && dir_cat="${dir_cat^}"
    
    category="$(get_category_display "$dir_cat")"
    desc="$(get_plugin_description "$plugin" "$p_name")"
    
    compat_text="Supported"
    compat_color="$GREEN"
    if ! is_plugin_supported "$plugin"; then
      compat_text="Unsupported"
      compat_color="$RED"
    fi
    
    printf "%-20s %-25s %b%-12s%b - %s\n" "$p_name" "($category)" "$compat_color" "$compat_text" "$RC" "$desc"
  done
  exit 0
fi

# ── Handle Uninstall Command ─────────────────────────────────────

if [[ "$COMMAND" == "uninstall" ]]; then
  if [[ ${#TARGETS[@]} -eq 0 ]]; then
    printf "%b\n" "${RED}✖ Please specify one or more plugins to uninstall.${RC}"
    exit 1
  fi
  run_selected_plugins uninstall "${TARGETS[@]}"
  exit 0
fi

# ── Handle Install Command ───────────────────────────────────────

if [[ "$COMMAND" == "install" ]]; then
  if [[ ${#TARGETS[@]} -eq 0 ]]; then
    # Interactive mode (only if running inside terminal TTY)
    if [[ -t 0 && -t 1 ]]; then
      SELECTED_PLUGINS=$(ui_select_plugins) || exit 0
      if [[ -n "$SELECTED_PLUGINS" ]]; then
        read -ra TARGETS <<< "$SELECTED_PLUGINS"
      else
        printf "%b\n" "${YELLOW}⚠ No plugins selected.${RC}"
        exit 0
      fi
    else
      # Non-interactive fallback
      run_default_profile
      exit 0
    fi
  fi

  # Apply confirmation block
  if [[ "$SKIP_CONFIRMATION" != "true" ]]; then
    confirm_installation "${TARGETS[@]}" || {
      printf "%b\n" "${YELLOW}⚠ Installation cancelled by user.${RC}"
      exit 0
    }
  fi

  # Run installation
  [[ -t 1 ]] && print_banner
  run_selected_plugins install "${TARGETS[@]}"

  # Success summary
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
fi
