plugin_describe() { echo "paru - Feature packed AUR helper (paru or paru-git)"; }
plugin_supported() { [[ "$PM" == "pacman" ]]; }

plugin_install() {
  if command -v paru >/dev/null 2>&1; then
    printf "%b\n" "${GREEN}✅ paru is already installed${RC}"
    return
  fi

  # Check if Chaotic AUR is available (has prebuilt paru-git)
  local pkg="paru"
  if grep -q "\[chaotic-aur\]" /etc/pacman.conf 2>/dev/null; then
    local choice
    choice=$(whiptail --title " Paru Variant " \
      --menu "Select which paru variant to install:" 12 50 3 \
      "paru"     "Stable (AUR, builds from source)" \
      "paru-git" "Git version (Chaotic AUR, prebuilt)" \
      3>&1 1>&2 2>&3) && pkg="$choice"
  fi

  printf "%b\n" "${CYAN}📦 Installing ${pkg}...${RC}"
  $ESCALATION_TOOL $PM -S --needed --noconfirm git base-devel

  if [[ "$pkg" == "paru-git" ]] && grep -q "\[chaotic-aur\]" /etc/pacman.conf 2>/dev/null; then
    # Install prebuilt from Chaotic AUR
    $ESCALATION_TOOL $PM -S --needed --noconfirm paru-git
  else
    # Build from AUR
    git clone https://aur.archlinux.org/${pkg}.git /tmp/paru-build
    (cd /tmp/paru-build && makepkg -si --noconfirm)
    rm -rf /tmp/paru-build
  fi
}
