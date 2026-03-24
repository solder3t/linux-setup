plugin_describe() { echo "httpie - A user-friendly command-line HTTP client"; }

plugin_install() {
  if command -v http >/dev/null 2>&1 || command -v httpie >/dev/null 2>&1; then
    echo "✅ httpie is already installed"
    return
  fi

  echo "📦 Installing httpie..."
  case "$PM" in
    pacman) $ESCALATION_TOOL $PM -S --needed --noconfirm httpie ;;
    dnf)    $ESCALATION_TOOL dnf install -y httpie ;;
    apt-get|nala)    $ESCALATION_TOOL apt-get install -y httpie ;;
  esac
}
