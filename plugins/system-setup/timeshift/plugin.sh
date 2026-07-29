plugin_describe() {
  echo "timeshift - Backup management via Timeshift (list, create, restore snapshots)"
}

plugin_install() {
  if ! command_exists timeshift; then
    printf "%b\n" "${YELLOW}Installing Timeshift...${RC}"
    case "$PM" in
      pacman)       $ESCALATION_TOOL "$PM" -S --noconfirm timeshift ;;
      *)            $ESCALATION_TOOL "$PM" install -y timeshift ;;
    esac
  fi

  timeshift_menu() {
    while true; do
      echo
      printf "%b\n" "${CYAN}=== Timeshift CLI Helper ===${RC}"
      printf "%b\n" "1) List Snapshots"
      printf "%b\n" "2) Create Snapshot"
      printf "%b\n" "3) Restore Snapshot"
      printf "%b\n" "4) Delete Snapshot"
      printf "%b\n" "5) Exit Helper"
      read -r -p "Select an option [1-5]: " opt
      case "$opt" in
        1) $ESCALATION_TOOL timeshift --list-snapshots ;;
        2)
          read -r -p "Enter snapshot comment: " comment
          $ESCALATION_TOOL timeshift --create --comments "$comment"
          ;;
        3)
          $ESCALATION_TOOL timeshift --list-snapshots
          read -r -p "Enter snapshot name to restore: " snap
          read -r -p "Enter target device (e.g. /dev/sda1): " dev
          read -r -p "Skip GRUB reinstall? [y/N]: " skipgrub
          if [[ "$skipgrub" == [Yy]* ]]; then
            $ESCALATION_TOOL timeshift --restore --snapshot "$snap" --target-device "$dev" --skip-grub --yes
          else
            read -r -p "Enter GRUB device (e.g. /dev/sda): " grubdev
            $ESCALATION_TOOL timeshift --restore --snapshot "$snap" --target-device "$dev" --grub-device "$grubdev" --yes
          fi
          ;;
        4)
          $ESCALATION_TOOL timeshift --list-snapshots
          read -r -p "Enter snapshot name to delete: " snap
          $ESCALATION_TOOL timeshift --delete --snapshot "$snap" --yes
          ;;
        5|*) break ;;
      esac
    done
  }
  
  if [[ "${SKIP_CONFIRMATION:-}" == "true" ]]; then
    printf "%b\n" "${YELLOW}Running in non-interactive/automation mode. Creating snapshot...${RC}"
    $ESCALATION_TOOL timeshift --create --comments "Auto-created by linux-setup"
  else
    timeshift_menu
  fi
}
