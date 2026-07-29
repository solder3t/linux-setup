plugin_describe() { echo "duf - Disk Usage/Free Utility - a better 'df' alternative"; }

plugin_install() {
  if command -v duf >/dev/null 2>&1; then
    echo "✅ duf is already installed"
    return
  fi

  echo "📦 Installing duf..."
  case "$PM" in
    pacman) $ESCALATION_TOOL $PM -S --needed --noconfirm duf ;;
    dnf)    $ESCALATION_TOOL dnf install -y duf ;;
    apt-get|nala)    
        # Available in newer releases
        $ESCALATION_TOOL apt-get install -y duf || echo "⚠️ duf might utilize a .deb download for older systems."
        ;;
  esac
}
