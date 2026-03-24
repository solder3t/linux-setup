plugin_describe() { echo "starship - The cross-shell prompt"; }

plugin_install() {
  if command -v starship >/dev/null 2>&1; then
    echo "✅ starship is already installed"
    return
  fi

  echo "📦 Installing starship..."
  case "$PM" in
    pacman) $ESCALATION_TOOL $PM -S --needed --noconfirm starship ;;
    dnf)    
        # Available in Fedora 33+
        $ESCALATION_TOOL dnf install -y starship || {
             echo "⚠️ starship not found in dnf. Installing via official script..."
             curl -sS https://starship.rs/install.sh | sh -s -- -y
        }
        ;;
    apt-get|nala)    
        # Not in standard Ubuntu repos usually.
        echo "ℹ️ Installing starship via official script..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
        ;;
  esac
  
  # Note: User needs to add `eval "$(starship init zsh)"` to .zshrc
  # We can optionally append it if we want to force it, but p10k is already there.
  # Better to let user switch if they want, or just print a message.
  echo "ℹ️ To use starship, allow it to init in your shell config (e.g., append 'eval \"\$(starship init zsh)\"' to ~/.zshrc)"
}
