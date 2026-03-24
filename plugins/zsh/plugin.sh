plugin_describe() { echo "zsh - Zsh + Oh-My-Zsh + Powerlevel10k + plugins"; }

plugin_install() {
  # ── Install ZSH packages ──
  if ! state_done zsh_pkgs; then
    printf "%b\n" "${CYAN}📦 Installing zsh packages...${RC}"
    case "$PM" in
      pacman)       $ESCALATION_TOOL $PM -S --needed --noconfirm zsh fastfetch lsd ;;
      dnf)          $ESCALATION_TOOL dnf install -y zsh fastfetch lsd ;;
      apt-get|nala) $ESCALATION_TOOL apt-get install -y zsh fastfetch lsd ;;
      zypper)       $ESCALATION_TOOL zypper --non-interactive install zsh lsd ;;
      apk)          $ESCALATION_TOOL apk add zsh lsd ;;
      xbps-install) $ESCALATION_TOOL xbps-install -Sy zsh lsd ;;
      eopkg)        $ESCALATION_TOOL eopkg install -y zsh ;;
    esac
    mark_done zsh_pkgs
  fi

  # ── Install Oh My Zsh + Powerlevel10k ──
  if ! state_done zsh_framework; then
    printf "%b\n" "${CYAN}🎨 Installing Oh My Zsh & Powerlevel10k...${RC}"

    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
      RUNZSH=no CHSH=no \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi

    P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    [[ -d "$P10K_DIR" ]] || \
      git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"

    mark_done zsh_framework
  fi

  # ── Install OMZ plugins ──
  ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  if [[ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions" ]]; then
    printf "%b\n" "${CYAN}  ➕ Installing zsh-autosuggestions${RC}"
    git clone --depth=1 \
      https://github.com/zsh-users/zsh-autosuggestions \
      "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
  fi

  if [[ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting" ]]; then
    printf "%b\n" "${CYAN}  ➕ Installing zsh-syntax-highlighting${RC}"
    git clone --depth=1 \
      https://github.com/zsh-users/zsh-syntax-highlighting \
      "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
  fi

  # ── Copy configs ──
  printf "%b\n" "${CYAN}📝 Installing zsh configuration files${RC}"

  if [[ ! -f "$HOME/.zshrc.installer-backup" ]]; then
    if [[ -f "$HOME/.zshrc" ]]; then
      printf "%b\n" "  📦 Backing up existing .zshrc"
      cp "$HOME/.zshrc" "$HOME/.zshrc.installer-backup"
    fi
    cp "$ROOT_DIR/zsh/.zshrc" "$HOME/.zshrc"
  else
    printf "%b\n" "${DIM}  ⏭ .zshrc already managed by installer${RC}"
  fi

  # p10k config
  if [[ -f "$ROOT_DIR/zsh/.p10k.zsh" ]]; then
    if [[ ! -f "$HOME/.p10k.zsh.installer-backup" && -f "$HOME/.p10k.zsh" ]]; then
       cp "$HOME/.p10k.zsh" "$HOME/.p10k.zsh.installer-backup"
    fi
    cp "$ROOT_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
  fi

  # ── Set default shell ──
  ZSH_PATH="$(command -v zsh)"

  if ! grep -qx "$ZSH_PATH" /etc/shells 2>/dev/null; then
    echo "$ZSH_PATH" | $ESCALATION_TOOL tee -a /etc/shells >/dev/null
  fi

  CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"

  if [[ "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
    printf "%b\n" "${CYAN}🔐 Setting zsh as default login shell${RC}"
    $ESCALATION_TOOL usermod -s "$ZSH_PATH" "$USER"
    printf "%b\n" "${DIM}ℹ  Log out and log back in to apply${RC}"
  fi
}
