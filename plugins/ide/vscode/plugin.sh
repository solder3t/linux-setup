plugin_describe() { echo "vscode - Visual Studio Code Editor"; }

plugin_install() {
    case "$PM" in

        # ── Debian / Ubuntu (apt-get or nala) ───────────────────────
        apt-get|nala)
            # 1. Install prerequisites
            "$ESCALATION_TOOL" apt-get install -y wget gpg apt-transport-https

            # 2. Import Microsoft's GPG signing key
            wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
                | "$ESCALATION_TOOL" gpg --dearmor \
                    -o /usr/share/keyrings/microsoft.gpg

            # 3. Add the VS Code apt repository (DEB822 format)
            printf 'Types: deb\nURIs: https://packages.microsoft.com/repos/code\nSuites: stable\nComponents: main\nArchitectures: amd64,arm64,armhf\nSigned-By: /usr/share/keyrings/microsoft.gpg\n' \
                | "$ESCALATION_TOOL" tee /etc/apt/sources.list.d/vscode.sources > /dev/null

            # 4. Update and install
            "$ESCALATION_TOOL" apt-get update
            "$ESCALATION_TOOL" apt-get install -y code
            ;;

        # ── Fedora / RHEL / CentOS (dnf) ────────────────────────────
        dnf)
            # 1. Import Microsoft's RPM GPG key and add yum repo
            "$ESCALATION_TOOL" rpm --import https://packages.microsoft.com/keys/microsoft.asc

            printf '[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc\n' \
                | "$ESCALATION_TOOL" tee /etc/yum.repos.d/vscode.repo > /dev/null

            # 2. Install
            "$ESCALATION_TOOL" dnf install -y code
            ;;

        # ── openSUSE / SLE (zypper) ──────────────────────────────────
        zypper)
            "$ESCALATION_TOOL" rpm --import https://packages.microsoft.com/keys/microsoft.asc

            printf '[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc\n' \
                | "$ESCALATION_TOOL" tee /etc/zypp/repos.d/vscode.repo > /dev/null

            "$ESCALATION_TOOL" zypper --non-interactive refresh
            "$ESCALATION_TOOL" zypper --non-interactive install code
            ;;

        # ── Arch Linux (pacman / AUR) ────────────────────────────────
        pacman)
            # The official AUR package is visual-studio-code-bin
            if [[ -n "${AUR_HELPER:-}" ]]; then
                "$AUR_HELPER" -Sy --needed --noconfirm visual-studio-code-bin
            else
                printf "%b\n" "${YELLOW}⚠ AUR helper (yay/paru) is required to install VS Code on Arch Linux.${RC}"
                setup_aur_helper
                if [[ -n "${AUR_HELPER:-}" ]]; then
                    "$AUR_HELPER" -Sy --needed --noconfirm visual-studio-code-bin
                else
                    printf "%b\n" "${RED}✖ Cannot install VS Code without an AUR helper.${RC}"
                    return 1
                fi
            fi
            ;;

        # ── Snap fallback ────────────────────────────────────────────
        *)
            if command_exists snap; then
                printf "%b\n" "${CYAN}📦 Falling back to snap for VS Code...${RC}"
                "$ESCALATION_TOOL" snap install --classic code
            else
                printf "%b\n" "${RED}✖ Unsupported package manager '$PM' and snap is not available.${RC}"
                printf "%b\n" "  Please install VS Code manually: https://code.visualstudio.com/docs/setup/linux"
                return 1
            fi
            ;;
    esac
}

plugin_uninstall() {
    case "$PM" in
        apt-get|nala)
            "$ESCALATION_TOOL" apt-get remove -y code
            "$ESCALATION_TOOL" rm -f /etc/apt/sources.list.d/vscode.sources
            "$ESCALATION_TOOL" rm -f /usr/share/keyrings/microsoft.gpg
            "$ESCALATION_TOOL" apt-get update
            ;;
        dnf)
            "$ESCALATION_TOOL" dnf remove -y code
            "$ESCALATION_TOOL" rm -f /etc/yum.repos.d/vscode.repo
            ;;
        zypper)
            "$ESCALATION_TOOL" zypper --non-interactive remove code
            "$ESCALATION_TOOL" rm -f /etc/zypp/repos.d/vscode.repo
            ;;
        pacman)
            [[ -n "${AUR_HELPER:-}" ]] \
                && "$AUR_HELPER" -Rns --noconfirm visual-studio-code-bin \
                || "$ESCALATION_TOOL" pacman -Rns --noconfirm visual-studio-code-bin
            ;;
        *)
            command_exists snap && "$ESCALATION_TOOL" snap remove code
            ;;
    esac
}
