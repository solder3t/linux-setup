plugin_describe() { echo "zen-browser - Experience tranquility while browsing the web"; }

plugin_install() {
  if command_exists zen-browser || command_exists zen || (command_exists flatpak && flatpak info app.zen_browser.zen >/dev/null 2>&1); then
    printf "%b\n" "${GREEN}✅ zen-browser is already installed${RC}"
  else
    printf "%b\n" "${CYAN}📦 Installing zen-browser...${RC}"
    case "$PM" in
      pacman)
          if grep -q "\[chaotic-aur\]" /etc/pacman.conf 2>/dev/null; then
            printf "%b\n" "${CYAN}  Using Chaotic AUR for zen-browser-bin...${RC}"
            $ESCALATION_TOOL $PM -S --needed --noconfirm zen-browser-bin
          elif [[ -n "${AUR_HELPER:-}" ]]; then
            printf "%b\n" "${CYAN}  Using $AUR_HELPER for zen-browser-bin...${RC}"
            $AUR_HELPER -S --needed --noconfirm zen-browser-bin
          else
            printf "%b\n" "${YELLOW}⚠ zen-browser-bin requires Chaotic AUR or an AUR helper (yay/paru).${RC}"
            return 1
          fi
          ;;
      dnf)
          printf "%b\n" "${CYAN}  Enabling Fedora COPR sneexy/zen-browser...${RC}"
          $ESCALATION_TOOL dnf copr enable -y sneexy/zen-browser
          $ESCALATION_TOOL dnf install -y zen-browser
          ;;
      apt-get|nala)
          # Flathub official method for Debian / Ubuntu based distros
          if ! command_exists flatpak; then
            printf "%b\n" "${CYAN}  Installing flatpak...${RC}"
            $ESCALATION_TOOL apt-get install -y flatpak
          fi
          printf "%b\n" "${CYAN}  Installing zen-browser via Flathub...${RC}"
          flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
          flatpak install -y flathub app.zen_browser.zen
          ;;
      *)
          if command_exists flatpak; then
            printf "%b\n" "${CYAN}  Installing zen-browser via Flathub...${RC}"
            flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
            flatpak install -y flathub app.zen_browser.zen
          else
            printf "%b\n" "${YELLOW}⚠ zen-browser installation not supported for $PM. Visit https://zen-browser.app${RC}"
            return 1
          fi
          ;;
    esac
  fi
}
