plugin_describe() { echo "yay - Yet Another Yogurt - AUR Helper"; }

plugin_install() {
  if command -v yay >/dev/null 2>&1; then
    echo "✅ yay is already installed"
    return
  fi
  
  echo "📦 Installing yay..."
  sudo pacman -S --needed --noconfirm git base-devel
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (cd /tmp/yay && makepkg -si --noconfirm)
  rm -rf /tmp/yay
}
