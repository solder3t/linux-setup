plugin_describe() { echo "neovim - Hyperextensible Vim-based text editor"; }

plugin_install() {
  if command -v nvim >/dev/null 2>&1; then
    echo "✅ neovim is already installed"
    return
  fi

  echo "📦 Installing neovim..."
  case "$PM" in
    pacman) $ESCALATION_TOOL $PM -S --needed --noconfirm neovim ;;
    dnf)    $ESCALATION_TOOL dnf install -y neovim ;;
    apt-get|nala)    
        # Check for glibc version or ubuntu version, as older ones have very old nvim.
        # Use Unstable PPA for valid recent neovim
        if ! command -v add-apt-repository >/dev/null 2>&1; then
             $ESCALATION_TOOL apt-get install -y software-properties-common
        fi
        
        # Only add if not present
        if ! grep -q "neovim-ppa/unstable" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
            echo "ℹ️ Adding Neovim PPA (Unstable) for recent version..."
            $ESCALATION_TOOL add-apt-repository -y ppa:neovim-ppa/unstable
            $ESCALATION_TOOL apt-get update
        fi
        
        $ESCALATION_TOOL apt-get install -y neovim 
        ;;
  esac
}
