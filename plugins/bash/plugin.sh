plugin_describe() { echo "shell - Bash shell configuration + Starship prompt"; }

plugin_install() {
  # ── Install Starship ──
  if ! command_exists starship; then
    printf "%b\n" "${CYAN}📦 Installing Starship prompt...${RC}"
    curl -sS https://starship.rs/install.sh | sh -s -- -y
  fi

  # ── Install Bash config ──
  printf "%b\n" "${CYAN}🐚 Installing Bash config...${RC}"
  mkdir -p "$HOME/.linux-setup"
  cp "$ROOT_DIR/bash/.bashrc" "$HOME/.linux-setup/bashrc"

  # Install Starship config
  if [[ -f "$ROOT_DIR/bash/starship.toml" ]]; then
    printf "%b\n" "${CYAN}🚀 Installing Starship configuration...${RC}"
    mkdir -p "$HOME/.config"
    cp "$ROOT_DIR/bash/starship.toml" "$HOME/.config/starship.toml"
  fi

  if ! grep -q "linux-setup bash config" "$HOME/.bashrc" 2>/dev/null; then
    cat >> "$HOME/.bashrc" <<'EOF'

# Source linux-setup bash config
[[ -f "$HOME/.linux-setup/bashrc" ]] && source "$HOME/.linux-setup/bashrc"
EOF
  fi
}
