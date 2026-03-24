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
  # Copy config.jsonc from the plugin directory (where this script resides)
  # We assume the script is sourced, so we use the location relative to the script
  # or simpler: we know where the plugin is located relative to root if running from root.
  # But better is to resolve the plugin dir.
  
  # However, in this repo structure, source happens from install.sh.
  # The most robust way in this specific repo context is often locating the file relative to the script file if possible, 
  # or relying on the fact that we are likely in the repo root or can find it.
  
  # Let's check how other plugins handle files or if there's a variable for plugin dir.
  # `run_selected_plugins` in `lib/plugin.sh` sources the script.
  # It doesn't seem to export a specific PLUGIN_DIR variable easily accessible inside the function 
  # without some trickery or assumption.
  # BUT, we know the path is `plugins/tools/fastfetch/config.jsonc` from the repo root.
  # install.sh sets ROOT_DIR.
  
  if [[ -f "$ROOT_DIR/plugins/tools/fastfetch/config.jsonc" ]]; then
      cp "$ROOT_DIR/plugins/tools/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
      echo "✅ fastfetch configuration installed."
  else
      echo "⚠️ Could not find config.jsonc to install."
  fi
}
