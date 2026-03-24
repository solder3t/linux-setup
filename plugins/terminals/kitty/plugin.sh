plugin_describe() { echo "kitty - Fast, feature-rich, GPU based terminal emulator"; }

plugin_install() {
  if ! command -v kitty >/dev/null 2>&1; then
    echo "📦 Installing kitty..."
    case "$PM" in
      pacman) $ESCALATION_TOOL $PM -S --needed --noconfirm kitty ;;
      dnf)    $ESCALATION_TOOL dnf install -y kitty ;;
      apt-get|nala)    $ESCALATION_TOOL apt-get install -y kitty ;;
    esac
  else
    echo "✅ kitty is already installed"
  fi

  # Install Config
  PLUGIN_DIR="$(dirname "$plugin")"
  CONFIG_SRC="$PLUGIN_DIR/kitty.conf"
  
  if [[ -f "$CONFIG_SRC" ]]; then
      echo "📝 Installing kitty config"
      mkdir -p "$HOME/.config/kitty"
      
      # Backup existing
      if [[ -f "$HOME/.config/kitty/kitty.conf" ]] && ! cmp -s "$CONFIG_SRC" "$HOME/.config/kitty/kitty.conf"; then
          echo "📦 Backing up existing kitty.conf"
          mv "$HOME/.config/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf.bak"
      fi
      
      cp "$CONFIG_SRC" "$HOME/.config/kitty/kitty.conf"
  fi
}
