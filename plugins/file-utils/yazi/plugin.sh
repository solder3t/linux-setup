plugin_describe() { echo "yazi - Blazing fast terminal file manager written in Rust"; }

plugin_install() {
  if command -v yazi >/dev/null 2>&1; then
    echo "✅ yazi is already installed"
    return
  fi

  echo "📦 Installing yazi..."
  case "$PM" in
    pacman) $ESCALATION_TOOL $PM -S --needed --noconfirm yazi ;;
    dnf)    
        # Might need copr on old fedora
        $ESCALATION_TOOL dnf install -y yazi 
        ;;
    apt-get|nala)    
        # Needs very new ubuntu or cargo install
        # Let's try apt, but it's likely missing on old systems.
        # Maybe suggest cargo install?
        if ! $ESCALATION_TOOL apt-get install -y yazi; then
             echo "⚠️ yazi not found in apt. You may need to install via Cargo: cargo install --locked yazi-fm"
        fi
        ;;
  esac
}
