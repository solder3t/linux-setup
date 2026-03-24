plugin_describe() { echo "ghostty - A fast, feature-rich, GPU-accelerated terminal emulator"; }

plugin_install() {
  if command_exists ghostty; then
    printf "%b\n" "${GREEN}✅ ghostty is already installed${RC}"
  else
    printf "%b\n" "${CYAN}📦 Installing ghostty...${RC}"
    case "$PM" in
      pacman)
          # Prefer ghostty-git from Chaotic AUR or AUR
          if grep -q "\[chaotic-aur\]" /etc/pacman.conf 2>/dev/null; then
            printf "%b\n" "${CYAN}  Using Chaotic AUR for ghostty-git...${RC}"
            $ESCALATION_TOOL $PM -S --needed --noconfirm ghostty-git
          elif [[ -n "${AUR_HELPER:-}" ]]; then
            printf "%b\n" "${CYAN}  Using $AUR_HELPER for ghostty-git...${RC}"
            $AUR_HELPER -S --needed --noconfirm ghostty-git
          else
            printf "%b\n" "${YELLOW}⚠ ghostty-git requires Chaotic AUR or an AUR helper.${RC}"
            printf "%b\n" "${YELLOW}  Run the chaotic-aur plugin first, or install yay/paru.${RC}"
            return 1
          fi
          ;;
      dnf)
          # Fedora 41+ has ghostty in repos via COPR
          if ! $ESCALATION_TOOL dnf install -y ghostty 2>/dev/null; then
            printf "%b\n" "${YELLOW}  Trying COPR pgdev/ghostty...${RC}"
            $ESCALATION_TOOL dnf copr enable -y pgdev/ghostty
            $ESCALATION_TOOL dnf install -y ghostty
          fi
          ;;
      apt-get|nala)
          # Not in standard repos yet; use the official .deb or build
          if apt-cache show ghostty >/dev/null 2>&1; then
            $ESCALATION_TOOL apt-get install -y ghostty
          else
            printf "%b\n" "${YELLOW}⚠ ghostty not in standard repos.${RC}"
            printf "%b\n" "${YELLOW}  Download from https://ghostty.org/download or build from source.${RC}"
            return 1
          fi
          ;;
      zypper)
          $ESCALATION_TOOL zypper --non-interactive install ghostty || {
            printf "%b\n" "${YELLOW}⚠ ghostty not available in zypper repos.${RC}"
            return 1
          }
          ;;
      *)
          printf "%b\n" "${YELLOW}⚠ ghostty installation not supported for $PM. Visit https://ghostty.org/download${RC}"
          return 1
          ;;
    esac
  fi

  # ── Install Config ──
  local PLUGIN_DIR
  PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local CONFIG_SRC="$ROOT_DIR/ghostty/config"

  # Fallback: check plugin directory too
  [[ ! -f "$CONFIG_SRC" ]] && CONFIG_SRC="$PLUGIN_DIR/config"

  if [[ -f "$CONFIG_SRC" ]]; then
    printf "%b\n" "${CYAN}📝 Installing ghostty config${RC}"
    mkdir -p "$HOME/.config/ghostty"

    # Backup existing config if different
    if [[ -f "$HOME/.config/ghostty/config" ]] && ! cmp -s "$CONFIG_SRC" "$HOME/.config/ghostty/config"; then
      printf "%b\n" "  📦 Backing up existing ghostty config"
      cp "$HOME/.config/ghostty/config" "$HOME/.config/ghostty/config.bak"
    fi

    cp "$CONFIG_SRC" "$HOME/.config/ghostty/config"
  fi
}
