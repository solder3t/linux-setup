plugin_describe() {
  echo "remove-snaps - Completely remove Snapd package manager and snap packages"
}

plugin_supported() {
  command_exists snap
}

plugin_install() {
  printf "%b\n" "${YELLOW}Removing snapd and snap packages...${RC}"
  # Remove snap packages
  if command_exists snap; then
    for s in $(snap list 2>/dev/null | awk 'NR>1 {print $1}'); do
      $ESCALATION_TOOL snap remove --purge "$s" || true
    done
  fi

  case "$PM" in
    pacman)
      $ESCALATION_TOOL "$PM" -Rns snapd --noconfirm
      ;;
    apt-get|nala)
      $ESCALATION_TOOL "$PM" remove --purge -y snapd
      $ESCALATION_TOOL "$PM" autoremove -y
      if [[ "$DISTRO_ID" == "ubuntu" ]]; then
        $ESCALATION_TOOL apt-mark hold snapd
      fi
      ;;
    dnf|zypper)
      $ESCALATION_TOOL "$PM" remove -y snapd
      ;;
  esac
  printf "%b\n" "${GREEN}✅ Snapd successfully removed.${RC}"
}
