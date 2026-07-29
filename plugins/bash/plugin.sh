plugin_describe() { echo "bash - Bash shell configuration"; }

plugin_install() {
  # ── Install Bash config ──
  printf "%b\n" "${CYAN}🐚 Installing Bash config...${RC}"
  mkdir -p "$HOME/.linux-setup"
  cp "$ROOT_DIR/configs/bash/.bashrc" "$HOME/.linux-setup/bashrc"

  # Install Starship config
  if [[ -f "$ROOT_DIR/configs/starship/starship.toml" ]]; then
    printf "%b\n" "${CYAN}🚀 Installing Starship configuration...${RC}"
    mkdir -p "$HOME/.config"
    cp "$ROOT_DIR/configs/starship/starship.toml" "$HOME/.config/starship.toml"
  fi

  if ! grep -q "linux-setup bash config" "$HOME/.bashrc" 2>/dev/null; then
    cat >> "$HOME/.bashrc" <<'EOF'

# Source linux-setup bash config
[[ -f "$HOME/.linux-setup/bashrc" ]] && source "$HOME/.linux-setup/bashrc"
EOF
  fi
}
