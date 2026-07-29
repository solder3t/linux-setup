plugin_describe() { echo "thefuck - Magnificent app which corrects your previous console command"; }

plugin_install() {
  if command -v thefuck >/dev/null 2>&1 || command -v fuck >/dev/null 2>&1; then
    echo "✅ thefuck is already installed"
    return
  fi

  echo "📦 Installing thefuck..."
  case "$PM" in
    pacman) $ESCALATION_TOOL $PM -S --needed --noconfirm thefuck ;;
    dnf)    
        # python3-thefuck usually
        $ESCALATION_TOOL dnf install -y thefuck
        ;;
    apt-get|nala)    
        $ESCALATION_TOOL apt-get install -y thefuck 
        ;;
  esac
  
  echo "ℹ️ You may need to add 'eval \$(thefuck --alias)' to your shell config."
  if [[ -f "$HOME/.zshrc" ]] && ! grep -q "thefuck" "$HOME/.zshrc"; then
       echo "eval \$(thefuck --alias)" >> "$HOME/.zshrc"
  fi
}
