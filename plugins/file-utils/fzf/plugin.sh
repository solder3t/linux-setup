plugin_describe() { echo "fzf - Command-line fuzzy finder"; }

plugin_install() {
  if command -v fzf >/dev/null 2>&1; then
    echo "✅ fzf is already installed"
    return
  fi

  echo "📦 Installing fzf..."
  case "$PM" in
    pacman) $ESCALATION_TOOL $PM -S --needed --noconfirm fzf ;;
    dnf)    $ESCALATION_TOOL dnf install -y fzf ;;
    apt-get|nala)    $ESCALATION_TOOL apt-get install -y fzf ;;
  esac
}
