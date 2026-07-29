plugin_describe() { echo "zoxide - A smarter cd command"; }

plugin_install() {
  if command -v zoxide >/dev/null 2>&1; then
    echo "✅ zoxide is already installed"
    return
  fi

  echo "📦 Installing zoxide..."
  case "$PM" in
    pacman) $ESCALATION_TOOL $PM -S --needed --noconfirm zoxide ;;
    dnf)    
        # Older fedora might not have it, but recent ones do.
        $ESCALATION_TOOL dnf install -y zoxide || {
            echo "⚠️ zoxide not found in dnf, trying simple curl install..."
            curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
        }
        ;;
    apt-get|nala)    
        $ESCALATION_TOOL apt-get install -y zoxide || {
            echo "⚠️ zoxide not found in apt, trying simple curl install..."
            curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
        }
        ;;
  esac
}
