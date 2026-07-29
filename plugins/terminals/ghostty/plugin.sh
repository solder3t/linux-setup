plugin_describe() { echo "ghostty - A fast, feature-rich, GPU-accelerated terminal emulator"; }

plugin_install() {
  if command_exists ghostty; then
    printf "%b\n" "${GREEN}✅ ghostty is already installed${RC}"
  else
    printf "%b\n" "${CYAN}📦 Installing ghostty...${RC}"
    case "$PM" in
      pacman)
          # Ghostty is available in official Arch [extra] repos as ghostty
          if $ESCALATION_TOOL $PM -S --needed --noconfirm ghostty 2>/dev/null; then
            printf "%b\n" "${GREEN}  ghostty installed from official Arch repos${RC}"
          elif grep -q "\[chaotic-aur\]" /etc/pacman.conf 2>/dev/null; then
            printf "%b\n" "${CYAN}  Using Chaotic AUR for ghostty-git...${RC}"
            $ESCALATION_TOOL $PM -S --needed --noconfirm ghostty-git
          elif [[ -n "${AUR_HELPER:-}" ]]; then
            printf "%b\n" "${CYAN}  Using $AUR_HELPER for ghostty-git...${RC}"
            $AUR_HELPER -S --needed --noconfirm ghostty-git
          else
            printf "%b\n" "${YELLOW}⚠ ghostty requires Arch extra repo or an AUR helper.${RC}"
            return 1
          fi
          ;;
      dnf)
          # Try direct install or enable recommended COPR scottames/ghostty
          if ! $ESCALATION_TOOL dnf install -y ghostty 2>/dev/null; then
            printf "%b\n" "${CYAN}  Enabling Fedora COPR scottames/ghostty...${RC}"
            $ESCALATION_TOOL dnf copr enable -y scottames/ghostty
            $ESCALATION_TOOL dnf install -y ghostty
          fi
          ;;
      apt-get|nala)
          # Use official apt repo if present, or mkasberg/ghostty-ubuntu installer / snap fallback
          if apt-cache show ghostty >/dev/null 2>&1; then
            $ESCALATION_TOOL apt-get install -y ghostty
          elif command_exists snap; then
            printf "%b\n" "${CYAN}  Installing ghostty via Snap...${RC}"
            $ESCALATION_TOOL snap install ghostty --classic
          else
            printf "%b\n" "${CYAN}  Installing ghostty via mkasberg/ghostty-ubuntu repository script...${RC}"
            curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh | bash
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
  local CONFIG_DIR="$ROOT_DIR/configs/ghostty"
  local CONFIG_SRC="$CONFIG_DIR/config"

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

  if [[ -d "$CONFIG_DIR/shaders" ]]; then
    printf "%b\n" "  🎨 Installing ghostty shaders..."
    mkdir -p "$HOME/.config/ghostty/shaders"
    cp -r "$CONFIG_DIR/shaders/"* "$HOME/.config/ghostty/shaders/"
  fi
}
