plugin_describe() { echo "paru - Feature packed AUR helper"; }

plugin_install() {
  if command -v paru >/dev/null 2>&1; then
    echo "✅ paru is already installed"
    return
  fi

  echo "📦 Installing paru..."
  sudo pacman -S --needed --noconfirm git base-devel
  git clone https://aur.archlinux.org/paru.git /tmp/paru
  (cd /tmp/paru && makepkg -si --noconfirm)
  rm -rf /tmp/paru
}
