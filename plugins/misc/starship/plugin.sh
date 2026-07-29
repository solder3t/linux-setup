plugin_describe() { echo "starship - The cross-shell prompt"; }

plugin_install() {
  if command -v starship >/dev/null 2>&1; then
    echo "✅ starship is already installed"
    return
  fi

  echo "📦 Installing starship..."
  case "$PM" in
    pacman) 
        $ESCALATION_TOOL $PM -S --needed --noconfirm starship 
        ;;
    dnf)    
        $ESCALATION_TOOL dnf install -y starship 2>/dev/null || {
          printf "%b\n" "${YELLOW}⚠️ starship not found in dnf repos. Installing via official script...${RC}"
          curl -sS https://starship.rs/install.sh | sh -s -- -y
        }
        ;;
    apt-get|nala)
        if apt-cache show starship >/dev/null 2>&1; then
          $ESCALATION_TOOL apt-get install -y starship
        else
          printf "%b\n" "${CYAN}ℹ️ Installing starship via official script...${RC}"
          curl -sS https://starship.rs/install.sh | sh -s -- -y
        fi
        ;;
    zypper)
        $ESCALATION_TOOL zypper --non-interactive install starship 2>/dev/null || {
          curl -sS https://starship.rs/install.sh | sh -s -- -y
        }
        ;;
    apk)
        $ESCALATION_TOOL apk add starship 2>/dev/null || {
          curl -sS https://starship.rs/install.sh | sh -s -- -y
        }
        ;;
    xbps-install)
        $ESCALATION_TOOL xbps-install -Sy starship 2>/dev/null || {
          curl -sS https://starship.rs/install.sh | sh -s -- -y
        }
        ;;
    eopkg)
        $ESCALATION_TOOL eopkg install -y starship 2>/dev/null || {
          curl -sS https://starship.rs/install.sh | sh -s -- -y
        }
        ;;
    *)
        printf "%b\n" "${CYAN}ℹ️ Installing starship via official script...${RC}"
        curl -sS https://starship.rs/install.sh | sh -s -- -y
        ;;
  esac
  
  # Note: User needs to add `eval "$(starship init zsh)"` to .zshrc
  # We can optionally append it if we want to force it, but p10k is already there.
  # Better to let user switch if they want, or just print a message.
  echo "ℹ️ To use starship, allow it to init in your shell config (e.g., append 'eval \"\$(starship init zsh)\"' to ~/.zshrc)"
}
