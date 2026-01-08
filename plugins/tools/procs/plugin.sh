plugin_describe() { echo "procs - A modern replacement for ps written in Rust"; }

plugin_install() {
  if command -v procs >/dev/null 2>&1; then
    echo "✅ procs is already installed"
    return
  fi

  echo "📦 Installing procs..."
  case "$PM" in
    pacman) sudo pacman -S --needed --noconfirm procs ;;
    dnf)    
        # Usually requires copr: dnf copr enable dalance/procs
        # But let's try standard install first or warn
        if ! sudo dnf install -y procs; then
            echo "⚠️ procs not found in standard dnf. Considering enabling copr: 'sudo dnf copr enable dalance/procs'"
        fi
        ;;
    apt)    
        # Not in standard apt.
        # Suggest cargo or snap?
        if command -v snap >/dev/null; then
            sudo snap install procs
        elif command -v cargo >/dev/null; then
            cargo install procs
        else
            echo "⚠️ procs requires snap or cargo on Ubuntu/Debian."
        fi
        ;;
  esac
}
