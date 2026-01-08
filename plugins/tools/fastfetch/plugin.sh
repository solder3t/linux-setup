plugin_describe() { echo "fastfetch - Like neofetch, but much faster"; }

plugin_install() {
  if command -v fastfetch >/dev/null 2>&1; then
    echo "✅ fastfetch is already installed"
    return
  fi

  echo "📦 Installing fastfetch..."
  case "$PM" in
    pacman) sudo pacman -S --needed --noconfirm fastfetch ;;
    dnf)    sudo dnf install -y fastfetch ;;
    apt)    
        # Available in newer Ubuntu/Debian versions (24.10+).
        # For older versions (22.04), we need a PPA.
        if ! apt-cache show fastfetch >/dev/null 2>&1; then
             echo "⚠️ fastfetch not found in default repos. Adding PPA..."
             if ! command -v add-apt-repository >/dev/null 2>&1; then
                 sudo apt install -y software-properties-common
             fi
             sudo add-apt-repository -y ppa:zhangsongcui3336/fastfetch
             sudo apt update
        fi
        
        sudo apt install -y fastfetch
        ;;
  esac
}
