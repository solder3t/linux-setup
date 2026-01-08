plugin_describe() { echo "duf - Disk Usage/Free Utility - a better 'df' alternative"; }

plugin_install() {
  if command -v duf >/dev/null 2>&1; then
    echo "✅ duf is already installed"
    return
  fi

  echo "📦 Installing duf..."
  case "$PM" in
    pacman) sudo pacman -S --needed --noconfirm duf ;;
    dnf)    sudo dnf install -y duf ;;
    apt)    
        # Available in newer releases
        sudo apt install -y duf || echo "⚠️ duf might utilize a .deb download for older systems."
        ;;
  esac
}
