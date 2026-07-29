plugin_describe() { echo "tmux - Terminal multiplexer"; }

plugin_install() {
  if command -v tmux >/dev/null 2>&1; then
    echo "✅ tmux is already installed"
    return
  fi

  echo "📦 Installing tmux..."
  case "$PM" in
    pacman) $ESCALATION_TOOL $PM -S --needed --noconfirm tmux ;;
    dnf)    $ESCALATION_TOOL dnf install -y tmux ;;
    apt-get|nala)    $ESCALATION_TOOL apt-get install -y tmux ;;
  esac
}
