plugin_describe() { echo "procs - A modern replacement for ps written in Rust"; }

plugin_install() {
  if command_exists procs; then
    echo "✅ procs is already installed"
    return
  fi

  echo "📦 Installing procs..."
  case "$PM" in
    pacman) $ESCALATION_TOOL $PM -S --needed --noconfirm procs ;;
    dnf)
        if ! $ESCALATION_TOOL dnf install -y procs; then
            printf "%b\n" "${YELLOW}⚠ procs not found in standard dnf. Consider: $ESCALATION_TOOL dnf copr enable dalance/procs${RC}"
        fi
        ;;
    apt-get|nala)
        if command_exists snap; then
            $ESCALATION_TOOL snap install procs
        elif command_exists cargo; then
            cargo install procs
        else
            printf "%b\n" "${YELLOW}⚠ procs requires snap or cargo on Ubuntu/Debian.${RC}"
        fi
        ;;
    zypper)       $ESCALATION_TOOL zypper --non-interactive install procs ;;
    apk)          printf "%b\n" "${YELLOW}⚠ procs not available in Alpine repos. Use cargo install procs.${RC}" ;;
    xbps-install) $ESCALATION_TOOL xbps-install -Sy procs ;;
  esac
}
