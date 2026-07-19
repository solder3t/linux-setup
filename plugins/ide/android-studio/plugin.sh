plugin_describe() { echo "android-studio - Official Android IDE"; }

plugin_install() {
    # Check if android-studio is available in repositories
    local available
    available=$(filter_available_packages "android-studio")
    if [[ -n "${available//[[:space:]]/}" ]]; then
        # Available via package manager (e.g. AUR on Arch)
        install_packages "android-studio" "android-studio"
    else
        # Fallback: run the custom online installer bootstrap
        printf "%b\n" "${CYAN}📦 Installing Android Studio via custom installer bootstrap...${RC}"
        curl -fsSL https://solder3t.github.io/android-studio-installer | bash -s -- -y
    fi
}

plugin_uninstall() {
    printf "%b\n" "${CYAN}🗑 Uninstalling Android Studio...${RC}"
    
    # Run the online uninstaller script to clean up system-wide and user-local components
    curl -fsSL https://raw.githubusercontent.com/solder3t/android-studio-installer/main/uninstall.sh | bash -s -- < /dev/null || true
    curl -fsSL https://raw.githubusercontent.com/solder3t/android-studio-installer/main/uninstall.sh | bash -s -- --user < /dev/null || true

    # Also remove package via package manager if it was installed that way
    case "$PM" in
        pacman)
            [[ -n "${AUR_HELPER:-}" ]] \
                && "$AUR_HELPER" -Rns --noconfirm android-studio \
                || "$ESCALATION_TOOL" pacman -Rns --noconfirm android-studio
            ;;
        apt-get|nala)
            "$ESCALATION_TOOL" apt-get remove -y android-studio
            ;;
        dnf)
            "$ESCALATION_TOOL" dnf remove -y android-studio
            ;;
        zypper)
            "$ESCALATION_TOOL" zypper --non-interactive remove android-studio
            ;;
    esac
}

plugin_installed() {
    command_exists android-studio
}
