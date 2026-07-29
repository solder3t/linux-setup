plugin_describe() { echo "meslo-nerd-font - MesloLGS NF (recommended for p10k)"; }

plugin_install() {
  local FONT_DIR="${HOME}/.local/share/fonts"
  local FONT_NAME="MesloLGS"
  
  # Check if font family is already registered or files exist
  if command -v fc-list >/dev/null 2>&1 && fc-list : family | grep -q "$FONT_NAME"; then
    printf "%b\n" "${GREEN}✅ $FONT_NAME is already installed${RC}"
    return
  elif [[ -f "$FONT_DIR/MesloLGS NF Regular.ttf" && -f "$FONT_DIR/MesloLGS NF Bold.ttf" ]]; then
    printf "%b\n" "${GREEN}✅ $FONT_NAME appears installed${RC}"
    return
  fi

  printf "%b\n" "${CYAN}📦 Installing $FONT_NAME Nerd Font...${RC}"
  mkdir -p "$FONT_DIR"
  
  # URLs from powerlevel10k recommended fonts repository
  local BASE_URL="https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master"
  local FONTS=(
    "MesloLGS NF Regular.ttf"
    "MesloLGS NF Bold.ttf"
    "MesloLGS NF Italic.ttf"
    "MesloLGS NF Bold Italic.ttf"
  )
  
  for font in "${FONTS[@]}"; do
    if [[ -f "$FONT_DIR/$font" ]]; then
      printf "%b\n" "  ${DIM}-> $font already exists, skipping.${RC}"
    else
      printf "%b\n" "  ⬇️ Downloading $font..."
      if curl -fsSL "$BASE_URL/${font// /%20}" -o "$FONT_DIR/$font"; then
        printf "%b\n" "     ${GREEN}...downloaded.${RC}"
      else
        printf "%b\n" "${RED}❌ Failed to download $font${RC}"
        return 1
      fi
    fi
  done
  
  printf "%b\n" "${CYAN}🔄 Updating font cache...${RC}"
  if command -v fc-cache >/dev/null 2>&1; then
    fc-cache -f "$FONT_DIR" >/dev/null 2>&1
  else
    printf "%b\n" "${YELLOW}⚠️ 'fc-cache' not found. You may need to install fontconfig or restart terminal.${RC}"
  fi
  
  printf "%b\n" "${GREEN}✅ Installed $FONT_NAME${RC}"
}
