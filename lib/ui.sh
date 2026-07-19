#!/usr/bin/env bash
# ui.sh — fzf-based TUI with preview pane and distro-aware filtering

VERSION="2.0.0"

# ── Print Environment Banner ────────────────────────────────────

print_banner() {
  local cols
  cols=$(tput cols 2>/dev/null || echo 60)
  local line
  line=$(printf '─%.0s' $(seq 1 "$cols"))

  printf "\n%b" "${CYAN}${BOLD}"
  cat <<'BANNER'
   ╦  ╦╔╗╔╦ ╦═╗ ╦   ╔═╗╔═╗╔╦╗╦ ╦╔═╗
   ║  ║║║║║ ║╔╩╦╝───╚═╗║╣  ║ ║ ║╠═╝
   ╩═╝╩╝╚╝╚═╝╩ ╚═   ╚═╝╚═╝ ╩ ╚═╝╩
BANNER
  printf "%b" "${RC}"

  printf "%b\n" "${DIM}${line}${RC}"
  printf "%b\n" "  ${BOLD}Version${RC}  ${DIM}${VERSION}${RC}"
  printf "%b\n" "  ${BOLD}Distro${RC}   ${DISTRO_NAME}"
  printf "%b\n" "  ${BOLD}Arch${RC}     ${ARCH}"
  printf "%b\n" "  ${BOLD}Pkg Mgr${RC}  ${PM}${AUR_HELPER:+ (+$AUR_HELPER)}"
  printf "%b\n" "  ${BOLD}Priv${RC}     ${ESCALATION_TOOL}${SUGROUP:+ (group: $SUGROUP)}"
  [[ -n "${INIT_MANAGER:-}" ]] && printf "%b\n" "  ${BOLD}Init${RC}     ${INIT_MANAGER}"
  printf "%b\n\n" "${DIM}${line}${RC}"
}

# ── fzf Plugin Selector ─────────────────────────────────────────

ui_select_plugins() {
  # Ensure fzf is available
  if ! command_exists fzf; then
    printf "%b\n" "${YELLOW}⚠ fzf is required for interactive mode. Installing fzf...${RC}"
    case "$PM" in
      pacman)       $ESCALATION_TOOL $PM -S --needed --noconfirm fzf ;;
      dnf)          $ESCALATION_TOOL dnf install -y fzf ;;
      apt-get|nala) $ESCALATION_TOOL apt-get install -y fzf ;;
      zypper)       $ESCALATION_TOOL zypper --non-interactive install fzf ;;
      apk)          $ESCALATION_TOOL apk add fzf ;;
      xbps-install) $ESCALATION_TOOL xbps-install -Sy fzf ;;
      eopkg)        $ESCALATION_TOOL eopkg install -y fzf ;;
      *)
        printf "%b\n" "${RED}✖ Unknown package manager, please install fzf manually.${RC}"
        return 1
        ;;
    esac
  fi

  if ! command_exists fzf; then
    printf "%b\n" "${RED}✖ fzf installation failed. Cannot start TUI.${RC}"
    return 1
  fi

  # Create a secure temp directory for tab-separated item lists
  local tmpdir
  tmpdir=$(mktemp -d)
  
  # Pre-create files for each tab to avoid file-not-found errors
  local tab
  for tab in all android system ide devtools files webterm design; do
    touch "$tmpdir/$tab"
  done

  # Build item list for fzf
  for plugin in "${PLUGINS_LOADED[@]}"; do
    local p_dir p_name c_dir dir_cat
    p_dir="$(dirname "$plugin")"
    p_name="$(basename "$p_dir")"
    c_dir="$(dirname "$p_dir")"
    dir_cat="$(basename "$c_dir")"

    # Skip unsupported plugins unless --show-unsupported is set
    if ! is_plugin_supported "$plugin"; then
      if [[ "${SHOW_UNSUPPORTED:-}" != "true" ]]; then
        continue
      fi
    fi

    [[ "$dir_cat" == "plugins" ]] && dir_cat="General"
    [[ "${dir_cat,,}" == "ide" ]] && dir_cat="IDE"
    [[ "$dir_cat" != "IDE" ]] && dir_cat="${dir_cat^}"

    local status="[${DIM}-${RC}]"
    if is_plugin_installed "$p_name" "$plugin"; then
      status="[${GREEN}✔${RC}]"
    fi

    local category
    category="$(get_category_display "$dir_cat")"

    local desc
    desc="$(get_plugin_description "$plugin" "$p_name")"

    # Align columns using pre-padded strings to avoid ANSI length issues in printf
    local name_str
    name_str=$(printf "%-20s" "$p_name")

    local cat_padded
    cat_padded=$(printf "%-25s" "($category)")
    local cat_str="${CYAN}${cat_padded}${RC}"

    local item="${status} ${name_str} ${cat_str} - ${desc}"
    
    # Write to all list
    printf "%b\n" "$item" >> "$tmpdir/all"

    # Route to category-specific files
    case "$dir_cat" in
      Android)
        printf "%b\n" "$item" >> "$tmpdir/android"
        ;;
      Bash|Zsh|General|System-utils|System-setup|Aur-helpers)
        printf "%b\n" "$item" >> "$tmpdir/system"
        ;;
      Editors|IDE)
        printf "%b\n" "$item" >> "$tmpdir/ide"
        ;;
      Developer-tools|Ccache|Clang)
        printf "%b\n" "$item" >> "$tmpdir/devtools"
        ;;
      File-utils)
        printf "%b\n" "$item" >> "$tmpdir/files"
        ;;
      Browsers|Terminals)
        printf "%b\n" "$item" >> "$tmpdir/webterm"
        ;;
      Fonts|Bootloader)
        printf "%b\n" "$item" >> "$tmpdir/design"
        ;;
      *)
        printf "%b\n" "$item" >> "$tmpdir/system"
        ;;
    esac
  done

  # Run fzf with custom theme and settings
  local fzf_colors="--color=bg+:#262626,fg+:#ffffff,hl:#5f87af,hl+:#5fd7ff,info:#af87ff,prompt:#5fd7ff,pointer:#5fd7ff,marker:#87ffaf,spinner:#5fd7ff,header:#87afaf"
  
  local fzf_opts=(
    "-m"
    "--ansi"
    "--layout=reverse"
    "--border"
    "--info=inline"
    "--prompt=⚡ Select Plugins > "
    "--header=Tabs: F1:All | F2:🤖Android | F3:🐚System | F4:💻IDE/Editor | F5:🛠️DevTools | F6:📂Files | F7:🌐Web/Term | F8:🎨Design
Instructions: Type to filter | TAB: Toggle selection | ENTER: Proceed | ESC: Quit"
    "--bind=f1:reload(cat '$tmpdir/all')+clear-query,f2:reload(cat '$tmpdir/android')+clear-query,f3:reload(cat '$tmpdir/system')+clear-query,f4:reload(cat '$tmpdir/ide')+clear-query,f5:reload(cat '$tmpdir/devtools')+clear-query,f6:reload(cat '$tmpdir/files')+clear-query,f7:reload(cat '$tmpdir/webterm')+clear-query,f8:reload(cat '$tmpdir/design')+clear-query"
    "--preview='$ROOT_DIR/install.sh' --preview {2}"
    "--preview-window=right:55%:border-left"
    $fzf_colors
  )

  local selections
  selections=$(cat "$tmpdir/all" | fzf "${fzf_opts[@]}") || {
    rm -rf "$tmpdir"
    return 1
  }

  # Clean up temp directory
  rm -rf "$tmpdir"

  # Extract selected plugin names
  local final_list=""
  while read -r line; do
    [[ -z "$line" ]] && continue
    local p_name
    p_name=$(echo "$line" | awk '{print $2}')
    final_list+="$p_name "
  done <<< "$selections"

  echo "$final_list"
}
