plugin_describe() { echo "chaotic-aur - Chaotic AUR repository for Arch Linux"; }
plugin_supported() { [[ "$PM" == "pacman" ]]; }

plugin_install() {
  if [[ "$PM" != "pacman" ]]; then
    printf "%b\n" "${YELLOW}⚠ Chaotic AUR is only supported on Arch-based systems${RC}"
    return 0
  fi

  if grep -q "\[chaotic-aur\]" /etc/pacman.conf 2>/dev/null; then
    printf "%b\n" "${GREEN}✅ Chaotic AUR is already configured${RC}"
    return 0
  fi

  printf "%b\n" "${CYAN}📦 Installing Chaotic AUR repository...${RC}"

  # Import and sign the key
  $ESCALATION_TOOL pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
  $ESCALATION_TOOL pacman-key --lsign-key 3056513887B78AEB

  # Install the keyring and mirrorlist packages
  $ESCALATION_TOOL $PM -U --noconfirm \
    'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
  $ESCALATION_TOOL $PM -U --noconfirm \
    'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

  # Append Chaotic AUR to pacman.conf
  printf "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist\n" | \
    $ESCALATION_TOOL tee -a /etc/pacman.conf

  # Sync databases
  $ESCALATION_TOOL $PM -Syu --noconfirm

  printf "%b\n" "${GREEN}✅ Chaotic AUR repository installed and enabled${RC}"
}

plugin_uninstall() {
  if [[ "$PM" != "pacman" ]]; then
    return 0
  fi

  if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf 2>/dev/null; then
    printf "%b\n" "${YELLOW}⚠ Chaotic AUR is not configured${RC}"
    return 0
  fi

  printf "%b\n" "${CYAN}🗑 Removing Chaotic AUR from pacman.conf...${RC}"
  $ESCALATION_TOOL sed -i '/\[chaotic-aur\]/,/Include.*chaotic-mirrorlist/d' /etc/pacman.conf
  $ESCALATION_TOOL $PM -Syu --noconfirm

  printf "%b\n" "${GREEN}✅ Chaotic AUR repository removed${RC}"
}
