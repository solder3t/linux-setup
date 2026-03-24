plugin_describe() { echo "htop - Interactive process viewer"; }

plugin_install() {
  if command -v htop >/dev/null 2>&1; then
    echo "✅ htop is already installed"
    return
  fi

  echo "📦 Installing htop..."
  case "$PM" in
    pacman) $ESCALATION_TOOL $PM -S --needed --noconfirm htop ;;
    dnf)    $ESCALATION_TOOL dnf install -y htop ;;
    apt-get|nala)    $ESCALATION_TOOL apt-get install -y htop ;;
  esac
}
