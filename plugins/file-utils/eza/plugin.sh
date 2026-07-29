plugin_describe() { echo "eza - A modern, maintained replacement for ls"; }

plugin_install() {
  if command -v eza >/dev/null 2>&1; then
    echo "✅ eza is already installed"
    return
  fi

  echo "📦 Installing eza..."
  case "$PM" in
    pacman) $ESCALATION_TOOL $PM -S --needed --noconfirm eza ;;
    dnf)    
        # Might need copr on old fedora, trying standard
        $ESCALATION_TOOL dnf install -y eza
        ;;
    apt-get|nala)    
        # Needs gpg key usually... 
        # For now, let's try apt, and warn.
        $ESCALATION_TOOL apt-get install -y eza || echo "⚠️ eza usually requires adding a gpg key/repo for Apt. Please check eza docs."
        ;;
  esac
}
