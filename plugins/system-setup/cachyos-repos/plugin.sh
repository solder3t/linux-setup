plugin_describe() {
  echo "cachyos-repos - Add CachyOS performance-optimized repositories and kernel"
}

plugin_supported() {
  [[ "$PM" == "pacman" ]]
}

plugin_install() {
  # Heuristic check if repo is installed
  if grep -q "cachyos" /etc/pacman.conf 2>/dev/null; then
    echo "✅ CachyOS repository already configured."
    return 0
  fi

  echo "📦 Installing CachyOS repository..."
  TMPDIR="$(mktemp -d)"
  curl -fsSL https://mirror.cachyos.org/cachyos-repo.tar.xz -o "$TMPDIR/cachyos-repo.tar.xz"
  tar -xf "$TMPDIR/cachyos-repo.tar.xz" -C "$TMPDIR"
  (cd "$TMPDIR/cachyos-repo" && $ESCALATION_TOOL ./cachyos-repo.sh)
  rm -rf "$TMPDIR"

  # Ask user to install CachyOS optimized kernel
  local install_kernel="n"
  if [[ "${SKIP_CONFIRMATION:-}" == "true" ]]; then
    install_kernel="y"
  else
    read -r -p "Do you want to install the optimized linux-cachyos-lts kernel? [y/N]: " install_kernel
  fi

  case "$install_kernel" in
    [Yy]*)
      echo "📦 Installing linux-cachyos-lts kernel and headers..."
      $ESCALATION_TOOL "$PM" -S --needed --noconfirm linux-cachyos-lts linux-cachyos-lts-headers
      if [[ -f /etc/default/grub ]]; then
        echo "📝 Updating GRUB default kernel..."
        local oldDefault
        oldDefault=$(grep GRUB_DEFAULT /etc/default/grub || echo "")
        local newDefault='GRUB_DEFAULT="Advanced options for Arch Linux>Arch Linux, with Linux linux-cachyos-lts"'
        if [[ -n "$oldDefault" ]]; then
          $ESCALATION_TOOL sed -i "s|${oldDefault}|${newDefault}|g" /etc/default/grub
        else
          echo "$newDefault" | $ESCALATION_TOOL tee -a /etc/default/grub >/dev/null
        fi
        $ESCALATION_TOOL grub-mkconfig -o /boot/grub/grub.cfg || true
      fi
      echo "✅ CachyOS kernel installed and configured."
      ;;
  esac
}
