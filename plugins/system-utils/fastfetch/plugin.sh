plugin_describe() { echo "fastfetch - Like neofetch, but much faster"; }

plugin_install() {
  if command -v fastfetch >/dev/null 2>&1; then
    echo "✅ fastfetch is already installed"
    return
  fi

  echo "📦 Installing fastfetch..."
  case "$PM" in
    pacman) $ESCALATION_TOOL $PM -S --needed --noconfirm fastfetch ;;
    dnf)    $ESCALATION_TOOL dnf install -y fastfetch ;;
    apt-get|nala)    
        # Available in newer Ubuntu/Debian versions (24.10+).
        # For older versions (22.04), we need a PPA.
        if ! apt-cache show fastfetch >/dev/null 2>&1; then
             echo "⚠️ fastfetch not found in default repos. Adding PPA..."
             if ! command -v add-apt-repository >/dev/null 2>&1; then
                 $ESCALATION_TOOL apt-get install -y software-properties-common
             fi
             $ESCALATION_TOOL add-apt-repository -y ppa:zhangsongcui3371/fastfetch
             $ESCALATION_TOOL apt-get update
        fi
        
        $ESCALATION_TOOL apt-get install -y fastfetch
        ;;
  esac
  
  # Install configuration
  echo "🔧 Configuring fastfetch..."
  mkdir -p "$HOME/.config/fastfetch"

  local PLUGIN_DIR
  PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  if [[ -f "$PLUGIN_DIR/config.jsonc" ]]; then
      # Copy all configs and subfolders (ascii, images, presets), then remove the plugin script itself
      cp -r "$PLUGIN_DIR/"* "$HOME/.config/fastfetch/"
      rm -f "$HOME/.config/fastfetch/plugin.sh"
      echo "✅ fastfetch configuration installed."
  else
      echo "⚠️ Could not find config.jsonc in $PLUGIN_DIR to install."
  fi
}
