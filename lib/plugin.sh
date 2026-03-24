#!/usr/bin/env bash
# plugin.sh — Plugin loader, runner, and distro-aware filtering

PLUGINS_LOADED=()
INSTALLED_SUMMARY=()

# ── Load Plugins ────────────────────────────────────────────────

load_plugins() {
  for plugin in "$ROOT_DIR/plugins"/*/*/plugin.sh "$ROOT_DIR/plugins"/*/plugin.sh; do
    [[ -f "$plugin" ]] || continue
    PLUGINS_LOADED+=("$plugin")
  done

  if [[ ${#PLUGINS_LOADED[@]} -eq 0 ]]; then
    printf "%b\n" "${RED}✖ No plugins found in $ROOT_DIR/plugins${RC}"
    exit 1
  fi
}

# ── Distro-Aware Plugin Support Check ───────────────────────────
# Plugins can declare a plugin_supported() function that returns
# non-zero if the plugin isn't applicable to the current system.
# If the function doesn't exist, the plugin is assumed universal.

is_plugin_supported() {
  local plugin_path="$1"
  local supported=0

  (
    source "$plugin_path" 2>/dev/null
    if declare -f plugin_supported >/dev/null 2>&1; then
      plugin_supported
    else
      return 0  # No restriction = supported everywhere
    fi
  ) || supported=1

  return $supported
}

# ── Get Plugin Metadata ─────────────────────────────────────────

get_plugin_description() {
  local plugin_path="$1"
  local p_name="$2"

  local desc
  desc=$(source "$plugin_path" && declare -f plugin_describe >/dev/null && plugin_describe || echo "$p_name") 2>/dev/null

  # Clean up description
  desc="${desc//[$'\t\r\n']/ }"
  # Remove "name - " prefix patterns
  if [[ "$desc" == *"$p_name - "* ]]; then desc="${desc#*"$p_name - "}"; fi
  # Capitalize first letter
  desc="${desc^}"

  echo "$desc"
}

# ── Category Display Names & Descriptions ───────────────────────
# Maps directory-based category names to display names + icons

declare -A CATEGORY_DISPLAY=(
  ["Android"]="Android Development"
  ["Bash"]="Shell & System"
  ["Zsh"]="Shell & System"
  ["Bootloader"]="Appearance"
  ["Browsers"]="Browsers"
  ["Ccache"]="Build Tools"
  ["Clang"]="Build Tools"
  ["Editors"]="Text Editors"
  ["Fonts"]="Appearance"
  ["IDE"]="IDEs"
  ["Terminals"]="Terminals"
  ["System-utils"]="System Utilities"
  ["File-utils"]="File & Search Utilities"
  ["Developer-tools"]="Developer Tools"
  ["Aur-helpers"]="AUR Helpers"
  ["Misc"]="Miscellaneous"
  ["General"]="Shell & System"
)

get_category_display() {
  local cat="$1"
  echo "${CATEGORY_DISPLAY[$cat]:-"📦 $cat"}"
}

# ── Run Hook on All Loaded Plugins ──────────────────────────────

run_plugin_hook() {
  local hook="$1"
  for plugin in "${PLUGINS_LOADED[@]}"; do
    (
      source "$plugin"
      if declare -f "plugin_$hook" >/dev/null; then
        plugin_"$hook"
      fi
    )
  done
}

# ── Run Selected Plugins ────────────────────────────────────────

run_selected_plugins() {
  local hook="$1"; shift
  local targets=("$@")

  for plugin in "${PLUGINS_LOADED[@]}"; do
    local p_name
    p_name="$(basename "$(dirname "$plugin")")"

    for t in "${targets[@]}"; do
      if [[ "$p_name" == "$t" ]]; then
        printf "%b\n" "${CYAN}${BOLD}▶ ${p_name}${RC}"

        local start_time
        start_time=$(date +%s)

        local plugin_exit=0
        (
          source "$plugin"
          if declare -f "plugin_$hook" >/dev/null; then
            plugin_"$hook"
          else
            printf "%b\n" "${YELLOW}  ⚠ No '${hook}' hook in ${p_name}${RC}"
          fi
        ) || plugin_exit=$?

        local end_time elapsed
        end_time=$(date +%s)
        elapsed=$((end_time - start_time))

        if [[ $plugin_exit -eq 0 ]]; then
          printf "%b\n" "${GREEN}  ✔ ${p_name} ${DIM}(${elapsed}s)${RC}"
          [[ "$hook" == "install" ]] && INSTALLED_SUMMARY+=("$p_name")
        else
          printf "%b\n" "${RED}  ✖ ${p_name} failed (exit $plugin_exit) ${DIM}(${elapsed}s)${RC}"
        fi
        echo
      fi
    done
  done
}

# ── Default Profile ─────────────────────────────────────────────

run_default_profile() {
  printf "%b\n" "${CYAN}📦 Running default linux-setup profile${RC}"
  local defaults
  IFS=' ' read -ra defaults <<< "${LINUX_SETUP_DEFAULT_PLUGINS:-integrations zsh ccache clang android}"
  run_selected_plugins install "${defaults[@]}"
}
