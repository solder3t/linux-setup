plugin_describe() { echo "vscode - Visual Studio Code Editor"; }

plugin_install() {
    # Arch: code or visual-studio-code-bin (AUR)
    # Debian/Ubuntu: code (requires repo setup usually, but snap is common. we'll try generic pkg first)
    # For now, simplistic approach relying on user having repos or AUR helper
    install_packages "vscode" "code"
}
