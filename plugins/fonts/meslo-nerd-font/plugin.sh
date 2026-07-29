plugin_describe() { echo "meslo-nerd-font - MesloLGS NF (recommended for p10k)"; }

plugin_install() {
  local FONT_DIR="${HOME}/.local/share/fonts"
  local FONT_NAME="MesloLGS"
  
  # Check if font family is already registered
  if command -v fc-list >/dev/null 2>&1; then
      if fc-list : family | grep -q "$FONT_NAME"; then
         echo "✅ $FONT_NAME is already installed"
         return
      fi
  elif [[ -f "$FONT_DIR/MesloLGS NF Regular.ttf" ]]; then
      # Fallback check if fontconfig is missing but file exists
         echo "✅ $FONT_NAME appears installed (checked files)"
         return
  fi

  echo "📦 Installing $FONT_NAME Nerd Font..."
  mkdir -p "$FONT_DIR"
  
  # URLs from powerlevel10k recommended fonts
  local BASE_URL="https://github.com/romkatv/powerlevel10k-media/raw/master"
  local FONTS=(
    "MesloLGS NF Regular.ttf"
    "MesloLGS NF Bold.ttf"
    "MesloLGS NF Italic.ttf"
    "MesloLGS NF Bold Italic.ttf"
  )
  
  for font in "${FONTS[@]}"; do
      if [[ -f "$FONT_DIR/$font" ]]; then
          echo "  -> $font already exists, skipping."
      else
          echo "  ⬇️ Downloading $font..."
          if curl -fsSL "$BASE_URL/${font// /%20}" -o "$FONT_DIR/$font"; then
              echo "     ...downloaded."
          else
              echo "❌ Failed to download $font"
              return 1
          fi
      fi
  done
  
  echo "🔄 Updating font cache..."
  if command -v fc-cache >/dev/null; then
      fc-cache -f "$FONT_DIR"
  else
      echo "⚠️ 'fc-cache' not found. You may need to install fontconfig or restart manually."
  fi
  
  echo "✅ Installed $FONT_NAME"
}
