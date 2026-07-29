plugin_describe() {
  echo "fstrim - Enable weekly SSD TRIM (fstrim.timer)"
}

plugin_supported() {
  [[ "$INIT_MANAGER" == "systemctl" ]]
}

plugin_install() {
  if ! command_exists fstrim; then
    printf "%b\n" "${YELLOW}Installing fstrim...${RC}"
    case "$PM" in
      pacman)       $ESCALATION_TOOL "$PM" -S --needed --noconfirm util-linux ;;
      apk)          $ESCALATION_TOOL "$PM" add util-linux ;;
      xbps-install) $ESCALATION_TOOL "$PM" -Sy util-linux ;;
      *)            $ESCALATION_TOOL "$PM" install -y util-linux ;;
    esac
  fi

  if ! systemctl cat fstrim.timer >/dev/null 2>&1; then
    printf "%b\n" "${RED}✖ fstrim.timer is not available on this system.${RC}"
    return 1
  fi

  printf "%b\n" "${YELLOW}Enabling weekly fstrim.timer...${RC}"
  $ESCALATION_TOOL systemctl enable --now fstrim.timer

  printf "%b\n" "${YELLOW}Running initial trim on all supported filesystems...${RC}"
  $ESCALATION_TOOL fstrim -av || true

  if systemctl is-active --quiet fstrim.timer; then
    printf "%b\n" "${GREEN}✅ Periodic SSD TRIM is active (weekly via fstrim.timer).${RC}"
  else
    printf "%b\n" "${RED}✖ fstrim.timer could not be activated.${RC}"
    return 1
  fi
}
