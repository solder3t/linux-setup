plugin_describe() {
  echo "grub-wuthering - Wuthering GRUB2 themes (interactive + auto-res)"
}

_wuthering_choose() {
  local prompt="$1"; shift
  local options=("$@")
  local choice
  echo
  echo "$prompt"
  select choice in "${options[@]}"; do
    [[ -n "$choice" ]] && echo "$choice" && return
    echo "Invalid choice, try again."
  done
}

_detect_grub_boot_flag() {
  [[ -d /boot/grub2 ]] && echo "--boot" || echo ""
}

_detect_screen_variant() {
  local fallback="2k"
  if [[ -z "$DISPLAY" ]] || ! command -v xrandr >/dev/null; then
    echo "$fallback"; return
  fi
  local width
  width="$(xrandr 2>/dev/null | awk '/\*/ {print $1}' | head -n1 | cut -d'x' -f1)"
  [[ -z "$width" ]] && echo "$fallback" && return
  if (( width >= 3200 )); then echo "4k"
  elif (( width >= 2200 )); then echo "2k"
  else echo "1080p"; fi
}

plugin_install() {
  THEMES=(changli jinxi jiyan yinlin anke weilinai kakaluo jianxin)
  SCREENS=(1080p 2k 4k)

  AUTO_SCREEN="$(_detect_screen_variant)"
  THEME="${WUTHERING_THEME:-}"
  SCREEN="${WUTHERING_SCREEN:-$AUTO_SCREEN}"

  [[ -z "$THEME" ]] && THEME="$(_wuthering_choose 'Select GRUB theme:' "${THEMES[@]}")"

  if [[ -z "$WUTHERING_SCREEN" ]]; then
    echo "Detected resolution → suggested: $SCREEN"
    SCREEN="$(_wuthering_choose 'Select screen resolution:' "${SCREENS[@]}")"
  fi

  TMPDIR="$(mktemp -d)"
  git clone --depth=1 https://github.com/vinceliuice/Wuthering-grub2-themes.git "$TMPDIR"
  BOOT_FLAG="$(_detect_grub_boot_flag)"
  cd "$TMPDIR"
  sudo bash install.sh --theme "$THEME" --screen "$SCREEN" $BOOT_FLAG
  rm -rf "$TMPDIR"
}

plugin_uninstall() {
  THEMES=(changli jinxi jiyan yinlin anke weilinai kakaluo jianxin)
  THEME="${WUTHERING_THEME:-}"
  [[ -z "$THEME" ]] && THEME="$(_wuthering_choose 'Select theme to remove:' "${THEMES[@]}")"
  TMPDIR="$(mktemp -d)"
  git clone --depth=1 https://github.com/vinceliuice/Wuthering-grub2-themes.git "$TMPDIR"
  cd "$TMPDIR"
  sudo bash install.sh --remove --theme "$THEME"
  rm -rf "$TMPDIR"
}
