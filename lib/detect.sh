. /etc/os-release

detect_distro() {
  case "$ID" in
    arch) PM=pacman ;;
    fedora) PM=dnf ;;
    ubuntu|debian|linuxmint|pop) PM=apt ;;
    *) echo "Unsupported distro: $ID"; exit 1 ;;
  esac
  echo "Detected $ID ($PM)"
}
