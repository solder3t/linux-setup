plugin_describe() { echo "httpie - A user-friendly command-line HTTP client"; }

plugin_install() {
  if command -v http >/dev/null 2>&1 || command -v httpie >/dev/null 2>&1; then
    echo "✅ httpie is already installed"
    return
  fi

  echo "📦 Installing httpie..."
  case "$PM" in
    pacman) sudo pacman -S --needed --noconfirm httpie ;;
    dnf)    sudo dnf install -y httpie ;;
    apt)    sudo apt install -y httpie ;;
  esac
}
