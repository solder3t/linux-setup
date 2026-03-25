plugin_describe() { echo "chrome - Google Chrome"; }
plugin_install() {
  if [[ "$PM" == "apt-get" || "$PM" == "nala" ]]; then
    echo "📦 Installing Google Chrome for Debian/Ubuntu..."
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    $ESCALATION_TOOL apt-get install -y ./google-chrome-stable_current_amd64.deb
    rm google-chrome-stable_current_amd64.deb
  elif [[ "$PM" == "dnf" ]]; then
    echo "📦 Installing Google Chrome for Fedora..."
    if ! $ESCALATION_TOOL dnf install -y google-chrome-stable; then
         echo "⚠️ Standard install failed, trying direct RPM..."
         $ESCALATION_TOOL dnf install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
    fi
  elif [[ "$PM" == "pacman" ]]; then
    echo "📦 Installing Google Chrome for Arch..."
    # Try pacman first (works if Chaotic AUR repo is configured)
    if $ESCALATION_TOOL pacman -Sy --needed --noconfirm google-chrome 2>/dev/null; then
      echo "✅ Installed google-chrome via pacman (Chaotic AUR)"
    else
      echo "⚠️ google-chrome not available via pacman, trying AUR helper..."
      # Ensure an AUR helper is available
      if [[ -z "${AUR_HELPER:-}" ]]; then
        if command_exists paru; then
          AUR_HELPER="paru"
        elif command_exists yay; then
          AUR_HELPER="yay"
        elif declare -f setup_aur_helper &>/dev/null; then
          setup_aur_helper
        fi
      fi

      if [[ -n "${AUR_HELPER:-}" ]]; then
        echo "📦 Installing google-chrome via $AUR_HELPER..."
        "$AUR_HELPER" -S --needed --noconfirm google-chrome
      else
        echo "❌ No AUR helper (paru/yay) available. Install one first:"
        echo "   ./install.sh install aur-helpers"
        return 1
      fi
    fi
  else
    echo "⚠️ Chrome installation not yet supported for $PM"
  fi
}
