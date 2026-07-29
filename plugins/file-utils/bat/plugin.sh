plugin_describe() { echo "bat - A cat(1) clone with wings"; }

plugin_install() {
  if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
    echo "✅ bat is already installed"
    # Ensure local bin link exists for debian/ubuntu
    if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
    fi
    return
  fi

  echo "📦 Installing bat..."
  case "$PM" in
    pacman) $ESCALATION_TOOL $PM -S --needed --noconfirm bat ;;
    dnf)    $ESCALATION_TOOL dnf install -y bat ;;
    apt-get|nala)    
        $ESCALATION_TOOL apt-get install -y bat
        mkdir -p "$HOME/.local/bin"
        ln -sf /usr/bin/batcat "$HOME/.local/bin/bat"
        ;;
  esac
}
