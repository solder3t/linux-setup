plugin_describe() { echo "clang - AOSP Clang prebuilts"; }

plugin_install() {
  state_done clang_prebuilts && {
    printf "%b\n" "${DIM}⏭ AOSP Clang prebuilts already installed${RC}"
    return
  }

  CLANG_DIR="$HOME/Android/clang"
  printf "%b\n" "${CYAN}📦 Installing AOSP Clang prebuilts to $CLANG_DIR...${RC}"
  mkdir -p "$CLANG_DIR"
  cd "$CLANG_DIR"

  if [[ ! -d bin ]]; then
    curl -fsSL \
      https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/main/clang-r522817.tar.gz \
      | tar -xz
  fi

  mark_done clang_prebuilts
}
