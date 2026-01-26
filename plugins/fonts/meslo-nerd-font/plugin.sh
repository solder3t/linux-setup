plugin_describe() { echo "meslo-nerd-font - MesloLGS NF (recommended for p10k)"; }

plugin_install() {
  FONT_DIR="${HOME}/.local/share/fonts"
  FONT_NAME="MesloLGS"
  
  if fc-list : family | grep -q "$FONT_NAME"; then
     echo "✅ $FONT_NAME is already installed"
     return
  fi

  echo "📦 Installing $FONT_NAME Nerd Font..."
  mkdir -p "$FONT_DIR"
  
  # URLs from powerlevel10k recommended fonts
  # https://github.com/romkatv/powerlevel10k#manual-font-installation
  
  local BASE_URL="https://github.com/romkatv/powerlevel10k-media/raw/master"
  local FONTS=(
    "MesloLGS NF Regular.ttf"
    "MesloLGS NF Bold.ttf"
    "MesloLGS NF Italic.ttf"
    "MesloLGS NF Bold Italic.ttf"
  )
  
  for font in "${FONTS[@]}"; do
      echo "⬇️ Downloading $font..."
      curl -fsSL "$BASE_URL/$font" -o "$FONT_DIR/$font"
  done
  
  echo "🔄 Updating font cache..."
  if command -v fc-cache >/dev/null; then
      fc-cache -f "$FONT_DIR"
  fi
  
  echo "✅ Installed $FONT_NAME"
}
