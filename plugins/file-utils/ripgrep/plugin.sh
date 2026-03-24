plugin_describe() { echo "ripgrep - Recursively search directories for a regex pattern"; }

plugin_install() {
  if command -v rg >/dev/null 2>&1; then
    echo "✅ ripgrep is already installed"
    return
  fi

  echo "📦 Installing ripgrep..."
  case "$PM" in
    pacman) $ESCALATION_TOOL $PM -S --needed --noconfirm ripgrep ;;
    dnf)    $ESCALATION_TOOL dnf install -y ripgrep ;;
    apt-get|nala)    $ESCALATION_TOOL apt-get install -y ripgrep ;;
  esac
}
