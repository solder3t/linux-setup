plugin_describe() { echo "alacritty - A cross-platform, GPU-accelerated terminal emulator"; }

plugin_install() {
  if ! command -v alacritty >/dev/null 2>&1; then
    echo "📦 Installing alacritty..."
    case "$PM" in
      pacman) $ESCALATION_TOOL $PM -S --needed --noconfirm alacritty ;;
      dnf)    $ESCALATION_TOOL dnf install -y alacritty ;;
      apt-get|nala)    
          # Alacritty is often in a PPA for Ubuntu or Cargo. 
          # Ubuntu 22.04+ has it in universe but might be old.
          # We'll try standard apt, if not available suggest PPA or ignore?
          # Actually, let's use the PPA if we can, or just apt install.
          if apt-cache show alacritty >/dev/null 2>&1; then
              $ESCALATION_TOOL apt-get install -y alacritty
          else
              echo "⚠️ Alacritty not found in default repos. install cargo and build? (Skipping for now to avoid long builds)"
              # add-apt-repository is interactive/risky?
              # Let's just try apt, if fail, warn.
          fi
          ;;
    esac
  else
    echo "✅ alacritty is already installed"
  fi

  # Install Config
  PLUGIN_DIR="$(dirname "$plugin")"
  CONFIG_SRC="$PLUGIN_DIR/alacritty.toml"
  
  if [[ -f "$CONFIG_SRC" ]]; then
      echo "📝 Installing alacritty config"
      mkdir -p "$HOME/.config/alacritty"
      
      # Backup existing
      if [[ -f "$HOME/.config/alacritty/alacritty.toml" ]] && ! cmp -s "$CONFIG_SRC" "$HOME/.config/alacritty/alacritty.toml"; then
          echo "📦 Backing up existing alacritty.toml"
          mv "$HOME/.config/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml.bak"
      fi
      
      cp "$CONFIG_SRC" "$HOME/.config/alacritty/alacritty.toml"
  fi
}
