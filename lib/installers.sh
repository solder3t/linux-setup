install_android_build_deps() {
  state_done android_deps && return
  case "$PM" in
    pacman) sudo pacman -Syy --noconfirm $(android_packages) ;;
    dnf) sudo dnf install -y --skip-unavailable $(android_packages) ;;
    apt) sudo apt update && sudo apt install -y $(android_packages) ;;
  esac
  mark_done android_deps
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
  sudo tee /etc/security/limits.d/99-android-build.conf >/dev/null <<EOF
* soft nofile 1048576
* hard nofile 1048576
* soft nproc 1048576
* hard nproc 1048576
* soft stack unlimited
* hard stack unlimited
EOF
  mark_done ulimits
}

install_zsh_stack() {
  state_done zsh && return
  case "$PM" in
    pacman) sudo pacman -S --noconfirm zsh fastfetch lsd ;;
    dnf) sudo dnf install -y zsh fastfetch lsd ;;
    apt) sudo apt install -y zsh fastfetch lsd ;;
  esac

  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  [[ -d "$P10K_DIR" ]] || git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"

  cp -n zsh/.zshrc "$HOME/.zshrc"
  cp -n zsh/.p10k.zsh "$HOME/.p10k.zsh"
  
# Set zsh as default shell
  if [[ "$SHELL" != "$(command -v zsh)" ]]; then
    echo "🔐 Setting zsh as default shell"
    sudo chsh -s "$(command -v zsh)" "$USER"
  fi
}
