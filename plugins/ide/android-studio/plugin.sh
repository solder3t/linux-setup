plugin_describe() { echo "android-studio - Official Android IDE"; }

plugin_install() {
    # Arch: android-studio (AUR)
    # Debian: often needs snap or manual download. 
    # relying on package manager availability
    install_packages "android-studio" "android-studio"
}
