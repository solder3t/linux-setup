plugin_describe() { echo "ncdu - NCurses Disk Usage"; }

plugin_install() {
  if command -v ncdu >/dev/null 2>&1; then
    echo "✅ ncdu is already installed"
    return
  fi

  echo "📦 Installing ncdu..."
  case "$PM" in
    pacman) $ESCALATION_TOOL $PM -S --needed --noconfirm ncdu ;;
    dnf)    $ESCALATION_TOOL dnf install -y ncdu ;;
    apt-get|nala)    $ESCALATION_TOOL apt-get install -y ncdu ;;
  esac
}
