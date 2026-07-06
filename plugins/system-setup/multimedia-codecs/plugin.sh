plugin_describe() {
  echo "multimedia-codecs - Swap to full ffmpeg and install multimedia codecs on Fedora"
}

plugin_supported() {
  [[ "$PM" == "dnf" ]]
}

plugin_install() {
  if [[ -f /etc/yum.repos.d/rpmfusion-free.repo && -f /etc/yum.repos.d/rpmfusion-nonfree.repo ]]; then
    printf "%b\n" "${YELLOW}Installing Multimedia Codecs...${RC}"
    $ESCALATION_TOOL "$PM" swap ffmpeg-free ffmpeg --allowerasing -y
    printf "%b\n" "${GREEN}✅ Multimedia Codecs installed.${RC}"
  else
    printf "%b\n" "${RED}✖ RPM Fusion repositories not found. Please set up RPM Fusion first!${RC}"
    return 1
  fi
}
