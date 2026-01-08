plugin_describe() { echo "direnv - Unclutter your .profile"; }

plugin_install() {
  if command -v direnv >/dev/null 2>&1; then
    echo "✅ direnv is already installed"
    return
  fi

  echo "📦 Installing direnv..."
  case "$PM" in
    pacman) sudo pacman -S --needed --noconfirm direnv ;;
    dnf)    sudo dnf install -y direnv ;;
    apt)    sudo apt install -y direnv ;;
  esac
  
  # Add hook to shell config?
  # The user likely has a comprehensive ZSH config managed by this repo.
  # We should check if we need to append the hook to .zshrc or .bashrc
  # But existing patterns suggest we might leave that to user or do it here.
  # Let's add a safe append if not present.
  
  if [[ -f "$HOME/.bashrc" ]] && ! grep -q "direnv hook bash" "$HOME/.bashrc"; then
      echo 'eval "$(direnv hook bash)"' >> "$HOME/.bashrc"
  fi
  if [[ -f "$HOME/.zshrc" ]] && ! grep -q "direnv hook zsh" "$HOME/.zshrc"; then
      echo 'eval "$(direnv hook zsh)"' >> "$HOME/.zshrc"
  fi
}
