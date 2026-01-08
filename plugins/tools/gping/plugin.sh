plugin_describe() { echo "gping - Ping, but with a graph"; }

plugin_install() {
  if command -v gping >/dev/null 2>&1; then
    echo "✅ gping is already installed"
    return
  fi

  echo "📦 Installing gping..."
  case "$PM" in
    pacman) sudo pacman -S --needed --noconfirm gping ;;
    dnf)    
        # Look for copr or standard?
        # Often in 'gping' package in updates
        sudo dnf install -y gping 
        ;;
    apt)    
        # Needs PPA or cargo
        echo "⚠️ gping often isn't in standard apt repos. Trying 'cargo install gping' fallback if cargo exists..."
        if command -v cargo >/dev/null; then
             cargo install gping
        else
             echo "❌ Cargo not found. Please install rust/cargo or check gping installation docs: https://github.com/orf/gping"
        fi
        ;;
  esac
}
