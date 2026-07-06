plugin_describe() {
  echo "system-cleanup - Free disk space, clean caches, vacuum journalctl, empty trash"
}

plugin_install() {
  printf "%b\n" "${YELLOW}Performing system package cleanup...${RC}"
  case "$PM" in
    apt-get|nala)
      $ESCALATION_TOOL "$PM" clean
      $ESCALATION_TOOL "$PM" autoremove -y 
      ;;
    zypper)
      $ESCALATION_TOOL "$PM" clean --all
      $ESCALATION_TOOL "$PM" packages --unneeded
      ;;
    dnf)
      $ESCALATION_TOOL "$PM" clean all
      $ESCALATION_TOOL "$PM" autoremove -y
      ;;
    pacman)
      $ESCALATION_TOOL "$PM" -Sc --noconfirm
      $ESCALATION_TOOL "$PM" -Rns $(pacman -Qtdq) --noconfirm > /dev/null 2>&1 || true
      ;;
    apk)
      $ESCALATION_TOOL "$PM" cache clean
      ;;
    xbps-install)
      $ESCALATION_TOOL xbps-remove -Ooy
      ;;
    eopkg)
      $ESCALATION_TOOL "$PM" -y remove-orphans
      ;;
  esac

  # Temp and logs cleanup
  [[ -d /var/tmp ]] && $ESCALATION_TOOL find /var/tmp -type f -atime +5 -delete
  [[ -d /tmp ]] && $ESCALATION_TOOL find /tmp -type f -atime +5 -delete
  [[ -d /var/log ]] && $ESCALATION_TOOL find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;
  if [[ "$INIT_MANAGER" == "systemctl" ]]; then
    $ESCALATION_TOOL journalctl --vacuum-time=3d
  fi

  # Home cache & Trash cleanup
  local clean_cache="n"
  if [[ "${SKIP_CONFIRMATION:-}" == "true" ]]; then
    clean_cache="y"
  else
    read -r -p "Clean up user cache files (~/.cache) and empty trash? [y/N]: " clean_cache
  fi
  case "$clean_cache" in
    [Yy]*)
      printf "%b\n" "${YELLOW}Cleaning up user cache and trash...${RC}"
      [[ -d "$HOME/.cache" ]] && find "$HOME/.cache/" -type f -atime +5 -delete
      [[ -d "$HOME/.local/share/Trash" ]] && find "$HOME/.local/share/Trash" -mindepth 1 -delete
      printf "%b\n" "${GREEN}✅ User cache and trash cleaned.${RC}"
      ;;
  esac
}
