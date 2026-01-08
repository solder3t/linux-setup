plugin_describe() { echo "neovim - Hyperextensible Vim-based text editor"; }

plugin_install() {
  if command -v nvim >/dev/null 2>&1; then
    echo "✅ neovim is already installed"
    return
  fi

  echo "📦 Installing neovim..."
  case "$PM" in
    pacman) sudo pacman -S --needed --noconfirm neovim ;;
    dnf)    sudo dnf install -y neovim ;;
    apt)    
        # Check for glibc version or ubuntu version, as older ones have very old nvim.
        # Use Unstable PPA for valid recent neovim
        if ! command -v add-apt-repository >/dev/null 2>&1; then
             sudo apt install -y software-properties-common
        fi
        
        # Only add if not present
        if ! grep -q "neovim-ppa/unstable" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
            echo "ℹ️ Adding Neovim PPA (Unstable) for recent version..."
            sudo add-apt-repository -y ppa:neovim-ppa/unstable
            sudo apt update
        fi
        
        sudo apt install -y neovim 
        ;;
  esac
}
