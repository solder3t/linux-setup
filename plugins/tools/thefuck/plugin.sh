plugin_describe() { echo "thefuck - Magnificent app which corrects your previous console command"; }

plugin_install() {
  if command -v thefuck >/dev/null 2>&1 || command -v fuck >/dev/null 2>&1; then
    echo "✅ thefuck is already installed"
    return
  fi

  echo "📦 Installing thefuck..."
  case "$PM" in
    pacman) sudo pacman -S --needed --noconfirm thefuck ;;
    dnf)    
        # python3-thefuck usually
        sudo dnf install -y thefuck
        ;;
    apt)    
        sudo apt install -y thefuck 
        ;;
  esac
  
  echo "ℹ️ You may need to add 'eval \$(thefuck --alias)' to your shell config."
  if [[ -f "$HOME/.zshrc" ]] && ! grep -q "thefuck" "$HOME/.zshrc"; then
       echo "eval \$(thefuck --alias)" >> "$HOME/.zshrc"
  fi
}
