plugin_describe() { echo "glow - Render markdown on the CLI"; }

plugin_install() {
  if command -v glow >/dev/null 2>&1; then
    echo "✅ glow is already installed"
    return
  fi

  echo "📦 Installing glow..."
  case "$PM" in
    pacman) $ESCALATION_TOOL $PM -S --needed --noconfirm glow ;;
    dnf)    
        # Charm bracelet repo usually needed
        # But some fedoras have it.
        if ! $ESCALATION_TOOL dnf install -y glow; then
             echo "⚠️ glow not found in default dnf repos. Consider adding charm-cli repo."
        fi
        ;;
    apt-get|nala)    
        # Needs charm repo
        # Use simple install if available, else warn
        if ! $ESCALATION_TOOL apt-get install -y glow; then
             echo "⚠️ glow requires adding the Charm key/repo. Please check https://github.com/charmbracelet/glow"
        fi
        ;;
  esac
}
