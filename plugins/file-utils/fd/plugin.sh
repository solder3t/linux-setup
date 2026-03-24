plugin_describe() { echo "fd - Simple, fast and user-friendly alternative to find"; }

plugin_install() {
  if command -v fd >/dev/null 2>&1 || command -v fdfind >/dev/null 2>&1; then
    echo "✅ fd is already installed"
    # Link for ubuntu
    if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    fi
    return
  fi

  echo "📦 Installing fd..."
  case "$PM" in
    pacman) $ESCALATION_TOOL $PM -S --needed --noconfirm fd ;;
    dnf)    
        # Usually fd-find
        $ESCALATION_TOOL dnf install -y fd-find 
        ;;
    apt-get|nala)    
        $ESCALATION_TOOL apt-get install -y fd-find
        mkdir -p "$HOME/.local/bin"
        ln -sf /usr/bin/fdfind "$HOME/.local/bin/fd"
        ;;
  esac
}
