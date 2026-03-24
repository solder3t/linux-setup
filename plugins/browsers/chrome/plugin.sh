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
  else
    echo "⚠️ Chrome installation not yet supported for $PM"
  fi
}
