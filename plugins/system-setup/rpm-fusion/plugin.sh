plugin_describe() {
  echo "rpm-fusion - Setup RPM Fusion free & non-free repositories for Fedora"
}

plugin_supported() {
  [[ "$PM" == "dnf" ]]
}

plugin_install() {
  if [[ ! -f /etc/yum.repos.d/rpmfusion-free.repo || ! -f /etc/yum.repos.d/rpmfusion-nonfree.repo ]]; then
    printf "%b\n" "${YELLOW}Installing RPM Fusion...${RC}"
    $ESCALATION_TOOL "$PM" install -y \
      "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
      "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
    
    fedora_version=$(rpm -E %fedora)
    if [[ "$fedora_version" -ge 41 ]]; then
      $ESCALATION_TOOL "$PM" config-manager setopt fedora-cisco-openh264.enabled=1
    else
      $ESCALATION_TOOL "$PM" config-manager --enable fedora-cisco-openh264
    fi
    $ESCALATION_TOOL "$PM" install -y rpmfusion-\*-appstream-data
    
    local install_tainted="n"
    if [[ "${SKIP_CONFIRMATION:-}" == "true" ]]; then
      install_tainted="y"
    else
      read -r -p "Do you want to install tainted repositories? [y/N]: " install_tainted
    fi
    case "$install_tainted" in
      [Yy]*)
        printf "%b\n" "${YELLOW}Installing RPM Fusion tainted repositories...${RC}"
        $ESCALATION_TOOL "$PM" install -y rpmfusion-free-release-tainted rpmfusion-nonfree-release-tainted
        if [[ "$fedora_version" -ge 41 ]]; then
          $ESCALATION_TOOL "$PM" config-manager setopt rpmfusion-free-tainted.enabled=1
          $ESCALATION_TOOL "$PM" config-manager setopt rpmfusion-nonfree-tainted.enabled=1
        else
          $ESCALATION_TOOL "$PM" config-manager --set-enabled rpmfusion-free-tainted
          $ESCALATION_TOOL "$PM" config-manager --set-enabled rpmfusion-nonfree-tainted
        fi
        printf "%b\n" "${GREEN}✅ RPM Fusion (including tainted) installed and enabled${RC}"
        ;;
      *)
        printf "%b\n" "${GREEN}✅ RPM Fusion installed and enabled${RC}"
        ;;
    esac
  else
    printf "%b\n" "${GREEN}✅ RPM Fusion is already installed${RC}"
  fi
}
