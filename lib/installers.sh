: "${PM:?PM not set — detect.sh must be sourced first}"
install_android_build_deps() {
  state_done android_deps && {
    echo "⏭ Android build dependencies already installed"
    return
  }

  echo "📦 Installing Android build dependencies"

  case "$PM" in
    pacman)
      # Try with pacman first
      if sudo pacman -Sy --needed --noconfirm $(android_packages); then
        echo "✅ Installed all packages via pacman"
      else
        echo "⚠️ Some packages failed to install with pacman."
        setup_aur_helper
        if [[ -n "$AUR_HELPER" ]]; then
          echo "🔄 Retrying with $AUR_HELPER..."
          $AUR_HELPER -Sy --needed --noconfirm $(android_packages)
        else
          echo "❌ Failed to install required packages and no AUR helper available."
          exit 1
        fi
      fi
      ;;
    dnf)
      # dnf already skips installed packages, but avoid unnecessary upgrades
      sudo dnf install -y --setopt=install_weak_deps=False \
        --skip-unavailable $(android_packages)
      ;;
    apt)
      sudo apt update
      sudo apt install -y --no-install-recommends $(android_packages)
      ;;
  esac

  mark_done android_deps
}

install_packages() {
  local state_key="$1"
  shift
  local packages="$@"

  state_done "$state_key" && {
    echo "⏭ Package group '$state_key' already installed"
    return
  }

  echo "📦 Installing packages for '$state_key'"

  case "$PM" in
    pacman)
      if sudo pacman -Sy --needed --noconfirm $packages; then
        echo "✅ Installed packages via pacman"
      else
        echo "⚠️ Some packages failed to install with pacman."
        setup_aur_helper
        if [[ -n "$AUR_HELPER" ]]; then
          echo "🔄 Retrying with $AUR_HELPER..."
          $AUR_HELPER -Sy --needed --noconfirm $packages
        else
          echo "❌ Failed to install required packages and no AUR helper available."
          return 1
        fi
      fi
      ;;
    dnf)
      sudo dnf install -y --setopt=install_weak_deps=False \
        --skip-unavailable $packages
      ;;
    apt)
      sudo apt update
      sudo apt install -y --no-install-recommends $packages
      ;;
  esac

  mark_done "$state_key"
}

install_optional_gcc_cross() {
  [[ "$PM" != "apt" ]] && return

  echo "🔍 Checking availability of GCC cross-compilers"

  if apt-cache show gcc-aarch64-linux-gnu >/dev/null 2>&1 &&
     apt-cache show gcc-arm-linux-gnueabi >/dev/null 2>&1; then
    echo "📦 Installing GCC cross-compilers"
    sudo apt install -y gcc-aarch64-linux-gnu gcc-arm-linux-gnueabi
  else
    echo "⚠️ GCC cross-compilers not available on this distro (skipping)"
    echo "ℹ️ Android builds will use Clang (recommended)"
  fi
}

setup_aur_helper() {
  [[ "$PM" != "pacman" ]] && return
  [[ -n "$AUR_HELPER" ]] && return

  echo "⚠️ No AUR helper detected (yay or paru)."
  echo "AUR helper is recommended for installing legacy dependencies (like ncurses5-compat-libs)."
  echo "Choose an AUR helper to install:"
  echo "1) yay (recommended)"
  echo "2) paru"
  echo "3) Skip (install only official Repo packages)"
  read -r -p "Select [1-3]: " choice

  case "$choice" in
    1)
      if [[ -f "$ROOT_DIR/plugins/tools/yay/plugin.sh" ]]; then
          echo "📦 Installing yay via plugin..."
          (source "$ROOT_DIR/plugins/tools/yay/plugin.sh" && plugin_install)
      else
          echo "❌ Plugin not found! Falling back to manual install."
          sudo pacman -S --needed --noconfirm git base-devel
          git clone https://aur.archlinux.org/yay.git /tmp/yay
          (cd /tmp/yay && makepkg -si --noconfirm)
          rm -rf /tmp/yay
      fi
      AUR_HELPER="yay"
      ;;
    2)
      if [[ -f "$ROOT_DIR/plugins/tools/paru/plugin.sh" ]]; then
          echo "📦 Installing paru via plugin..."
          (source "$ROOT_DIR/plugins/tools/paru/plugin.sh" && plugin_install)
      else
          echo "❌ Plugin not found! Falling back to manual install."
          sudo pacman -S --needed --noconfirm git base-devel
          git clone https://aur.archlinux.org/paru.git /tmp/paru
          (cd /tmp/paru && makepkg -si --noconfirm)
          rm -rf /tmp/paru
      fi
      AUR_HELPER="paru"
      ;;
    *)
      echo "⏭ Skipping AUR helper installation."
      ;;
  esac
  export AUR_HELPER
}

arch_pre_setup() {
  [[ "$PM" != "pacman" ]] && return
  state_done arch_multilib && return

  if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
    sudo pacman -Syy
  fi
  mark_done arch_multilib
}

ubuntu_ncurses_compat() {
  [[ "$PM" != "apt" ]] && return
  state_done ncurses5 && return

  LIB="/usr/lib/x86_64-linux-gnu"
  [[ -f "$LIB/libncurses.so.6" && ! -e "$LIB/libncurses.so.5" ]] && sudo ln -s "$LIB/libncurses.so.6" "$LIB/libncurses.so.5"
  [[ -f "$LIB/libtinfo.so.6" && ! -e "$LIB/libtinfo.so.5" ]] && sudo ln -s "$LIB/libtinfo.so.6" "$LIB/libtinfo.so.5"

  mark_done ncurses5
}

install_android_udev() {
  state_done udev && return
  [[ "$PM" == "pacman" ]] && { mark_done udev; return; }

  sudo curl -fsSL https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules -o /etc/udev/rules.d/51-android.rules
  sudo udevadm control --reload-rules
  sudo udevadm trigger

  mark_done udev
}

install_repo_tool() {
  state_done repo && return
  if [[ "$PM" == "apt" ]]; then
    mkdir -p "$HOME/bin"
    [[ -x "$HOME/bin/repo" ]] || {
      curl -fsSL https://storage.googleapis.com/git-repo-downloads/repo -o "$HOME/bin/repo"
      chmod +x "$HOME/bin/repo"
    }
  fi
  mark_done repo
}

install_clang_prebuilts() {
  state_done clang && return
  CLANG_DIR="$HOME/android/clang"
  mkdir -p "$CLANG_DIR"
  cd "$CLANG_DIR"
  if [[ ! -d bin ]]; then
    curl -fsSL https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/main/clang-r522817.tar.gz | tar -xz
  fi
  mark_done clang
}

configure_ccache() {
  state_done ccache && return
  mkdir -p "$HOME/.cache/ccache" "$HOME/.ccache"
  cat > "$HOME/.ccache/ccache.conf" <<EOF
max_size = 50G
compression = true
compiler_check = content
EOF
  ccache -z || true
  mark_done ccache
}

configure_git_lfs() {
  state_done gitlfs && return
  git lfs install --skip-repo
  mark_done gitlfs
}

configure_ulimits() {
  state_done ulimits && return

  echo "⚙️ Configuring ulimits for Android builds"

  # Ensure directory exists (important on Arch / minimal systems)
  sudo mkdir -p /etc/security/limits.d

  sudo tee /etc/security/limits.d/99-android-build.conf >/dev/null <<'EOF'
* soft nofile 1048576
* hard nofile 1048576
* soft nproc  1048576
* hard nproc  1048576
* soft stack  unlimited
* hard stack  unlimited
EOF

  mark_done ulimits
}

install_bash_config() {
  echo "🐚 Installing Bash config"
  mkdir -p "$HOME/.linux-setup"
  cp "$ROOT_DIR/bash/.bashrc" "$HOME/.linux-setup/bashrc"

  if ! grep -q "linux-setup bash config" "$HOME/.bashrc"; then
    cat >> "$HOME/.bashrc" <<'EOF'

# Source linux-setup bash config
[[ -f "$HOME/.linux-setup/bashrc" ]] && source "$HOME/.linux-setup/bashrc"
EOF
  fi
}

install_zsh_stack() {
# Install ZSH-related packages
  if ! state_done zsh_pkgs; then
    echo "📦 Installing zsh packages"

    case "$PM" in
      pacman) sudo pacman -S --needed --noconfirm zsh fastfetch lsd ;;
      dnf)    sudo dnf install -y zsh fastfetch lsd ;;
      apt)    sudo apt install -y zsh fastfetch lsd ;;
    esac

    mark_done zsh_pkgs
  fi

# Install Oh My Zsh + Powerlevel10k
  if ! state_done zsh_framework; then
    echo "🎨 Installing Oh My Zsh & Powerlevel10k"

    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
      RUNZSH=no CHSH=no \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi

    P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    [[ -d "$P10K_DIR" ]] || \
      git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"

    mark_done zsh_framework
  fi

# Install Oh My Zsh plugins
  ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  
  if [[ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions" ]]; then
      echo "➕ Installing zsh-autosuggestions"
      git clone --depth=1 \
        https://github.com/zsh-users/zsh-autosuggestions \
        "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
  fi
  
  if [[ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting" ]]; then
      echo "➕ Installing zsh-syntax-highlighting"
      git clone --depth=1 \
        https://github.com/zsh-users/zsh-syntax-highlighting \
        "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
  fi

# Copy configs (ALWAYS SAFE, NEVER SKIPPED)
  echo "📝 Installing zsh configuration files"
    
  if [[ ! -f "$HOME/.zshrc.installer-backup" ]]; then
    if [[ -f "$HOME/.zshrc" ]]; then
        echo "📦 Backing up existing .zshrc"
        cp "$HOME/.zshrc" "$HOME/.zshrc.installer-backup"
    fi
    
      echo "➡️ Installing repo .zshrc"
      cp "$ROOT_DIR/zsh/.zshrc" "$HOME/.zshrc"
    else
      echo "⏭ .zshrc already managed by installer"
  fi
  
# p10k config (safe overwrite-once)
  if [[ -f "$ROOT_DIR/zsh/.p10k.zsh" ]]; then
    if [[ ! -f "$HOME/.p10k.zsh.installer-backup" && -f "$HOME/.p10k.zsh" ]]; then
       cp "$HOME/.p10k.zsh" "$HOME/.p10k.zsh.installer-backup"
    fi
      cp "$ROOT_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
  fi

# Set default shell (robust)
  ZSH_PATH="$(command -v zsh)"
  
  if ! grep -qx "$ZSH_PATH" /etc/shells; then
      echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
  fi
  
  CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"
  
  if [[ "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
    echo "🔐 Setting zsh as default login shell"
    sudo usermod -s "$ZSH_PATH" "$USER"
    echo "ℹ️ Log out and log back in to apply"
  fi
}
