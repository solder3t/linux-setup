plugin_describe() { echo "delta - A syntax-highlighting pager for git, diff, and grep"; }

plugin_install() {
  if command -v delta >/dev/null 2>&1; then
    echo "✅ delta is already installed"
    return
  fi

  echo "📦 Installing delta..."
  case "$PM" in
    pacman) $ESCALATION_TOOL $PM -S --needed --noconfirm git-delta ;;
    dnf)    
        # git-delta usually
        $ESCALATION_TOOL dnf install -y git-delta || $ESCALATION_TOOL dnf install -y delta
        ;;
    apt-get|nala)    
        # Has git-delta in newer repos?
        $ESCALATION_TOOL apt-get install -y git-delta || echo "⚠️ delta might require manual install (cargo/binary) on older apt systems"
        ;;
  esac
}
