plugin_describe() { echo "lazygit - Simple terminal UI for git commands"; }

plugin_install() {
  if command -v lazygit >/dev/null 2>&1; then
    echo "✅ lazygit is already installed"
    return
  fi

  echo "📦 Installing lazygit..."
  case "$PM" in
    pacman) $ESCALATION_TOOL $PM -S --needed --noconfirm lazygit ;;
    dnf)    $ESCALATION_TOOL dnf install -y lazygit ;;
    apt-get|nala)    
        # LazyGit often requires PPA or direct install on older Ubuntus
        # We will try apt, if fail, suggest PPA? Or just do the go install/binary?
        # Let's try apt first.
        # For robustness, we could pull the binary from github releases if apt fails, 
        # but that's complex for this snippet.
        $ESCALATION_TOOL apt-get install -y lazygit
        ;;
  esac
}
