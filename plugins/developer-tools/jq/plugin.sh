plugin_describe() { echo "jq - Command-line JSON processor"; }

plugin_install() {
  if command -v jq >/dev/null 2>&1; then
    echo "✅ jq is already installed"
    return
  fi

  echo "📦 Installing jq..."
  case "$PM" in
    pacman) $ESCALATION_TOOL $PM -S --needed --noconfirm jq ;;
    dnf)    $ESCALATION_TOOL dnf install -y jq ;;
    apt-get|nala)    $ESCALATION_TOOL apt-get install -y jq ;;
  esac
}
