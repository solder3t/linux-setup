plugin_describe() { echo "tldr - Collaborative cheatsheets for console commands"; }

plugin_install() {
  if command -v tldr >/dev/null 2>&1 || command -v tealdeer >/dev/null 2>&1; then
    echo "✅ tldr/tealdeer is already installed"
    return
  fi

  echo "📦 Installing tldr..."
  case "$PM" in
    pacman) $ESCALATION_TOOL $PM -S --needed --noconfirm tealdeer ;;
    dnf)    
        $ESCALATION_TOOL dnf install -y tealdeer || $ESCALATION_TOOL dnf install -y tldr 
        ;;
    apt-get|nala)    
        $ESCALATION_TOOL apt-get install -y tldr 
        # apt tldr requires initially updating cache
        echo "ℹ️ Updating tldr cache..."
        tldr --update || true
        ;;
  esac
}
