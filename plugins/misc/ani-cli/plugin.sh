plugin_describe() { echo "ani-cli - Browse and play anime from the terminal"; }

plugin_install() {
  if command_exists ani-cli; then
    printf "%b\n" "${GREEN}✅ ani-cli is already installed${RC}"
    return
  fi

  printf "%b\n" "${CYAN}📦 Installing ani-cli...${RC}"
  case "$PM" in
    pacman)
        if [[ -n "${AUR_HELPER:-}" ]]; then
          $AUR_HELPER -S --needed --noconfirm ani-cli
        elif grep -q "\[chaotic-aur\]" /etc/pacman.conf 2>/dev/null; then
          $ESCALATION_TOOL $PM -S --needed --noconfirm ani-cli
        else
          printf "%b\n" "${YELLOW}⚠ ani-cli requires an AUR helper or Chaotic AUR on Arch.${RC}"
          return 1
        fi
        ;;
    dnf)
        # Install dependencies then from source
        $ESCALATION_TOOL dnf install -y curl mpv fzf
        _anicli_from_source
        ;;
    apt-get|nala)
        $ESCALATION_TOOL apt-get install -y curl mpv fzf
        _anicli_from_source
        ;;
    *)
        printf "%b\n" "${YELLOW}  Installing from source...${RC}"
        _anicli_from_source
        ;;
  esac
}

_anicli_from_source() {
  printf "%b\n" "${CYAN}  Installing ani-cli from source...${RC}"
  local tmpdir
  tmpdir="$(mktemp -d)"
  git clone --depth=1 https://github.com/pystardust/ani-cli.git "$tmpdir"
  $ESCALATION_TOOL install -Dm755 "$tmpdir/ani-cli" /usr/local/bin/ani-cli
  rm -rf "$tmpdir"
  printf "%b\n" "${GREEN}✅ ani-cli installed to /usr/local/bin/ani-cli${RC}"
}
