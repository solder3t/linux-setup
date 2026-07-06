#!/usr/bin/env bash
# installers.sh — Shared installation utilities used by plugins
#
# This file provides generic helpers. Plugin-specific install logic
# lives inside each plugin's own plugin.sh file.

: "${PM:?PM not set — detect.sh must be sourced first}"

# ── Filter Available Packages ───────────────────────────────────

filter_available_packages() {
  local filtered=""
  for pkg in "$@"; do
    local available=1
    case "$PM" in
      pacman)
        pacman -Si "$pkg" >/dev/null 2>&1 && available=0
        ;;
      apt-get|nala)
        apt-cache show "$pkg" >/dev/null 2>&1 && available=0
        ;;
      dnf)
        (dnf list "$pkg" >/dev/null 2>&1 || dnf provides "$pkg" >/dev/null 2>&1) && available=0
        ;;
      zypper)
        zypper info "$pkg" >/dev/null 2>&1 && available=0
        ;;
      apk)
        apk info -e "$pkg" >/dev/null 2>&1 && available=0
        ;;
      xbps-install)
        xbps-query -R "$pkg" >/dev/null 2>&1 && available=0
        ;;
      eopkg)
        eopkg info "$pkg" >/dev/null 2>&1 && available=0
        ;;
      *)
        available=0
        ;;
    esac

    if [[ $available -eq 0 ]]; then
      filtered+="$pkg "
    else
      printf "%b\n" "${YELLOW}⚠ Package '$pkg' is not available in repository, skipping...${RC}" >&2
    fi
  done
  echo "$filtered"
}

# ── Generic Package Installer ───────────────────────────────────

install_packages() {
  local state_key="$1"
  shift
  local packages="$*"

  state_done "$state_key" && {
    printf "%b\n" "${DIM}⏭ Package group '${state_key}' already installed${RC}"
    return
  }

  local filtered_packages
  filtered_packages=$(filter_available_packages $packages)

  if [[ -z "${filtered_packages//[[:space:]]/}" ]]; then
    printf "%b\n" "${YELLOW}⚠ No packages in group '${state_key}' are available to install.${RC}"
    mark_done "$state_key"
    return 0
  fi

  printf "%b\n" "${CYAN}📦 Installing packages for '${state_key}'${RC}"

  case "$PM" in
    pacman)
      if "$ESCALATION_TOOL" "$PM" -Sy --needed --noconfirm $filtered_packages; then
        printf "%b\n" "${GREEN}✅ Installed via pacman${RC}"
      else
        printf "%b\n" "${YELLOW}⚠ Some packages failed with pacman${RC}"
        setup_aur_helper
        if [[ -n "${AUR_HELPER:-}" ]]; then
          printf "%b\n" "${YELLOW}🔄 Retrying with $AUR_HELPER...${RC}"
          "$AUR_HELPER" -Sy --needed --noconfirm $filtered_packages
        else
          printf "%b\n" "${RED}✖ Failed and no AUR helper available${RC}"
          return 1
        fi
      fi
      ;;
    nala)
      "$ESCALATION_TOOL" nala install -y $filtered_packages
      ;;
    apt-get)
      "$ESCALATION_TOOL" apt-get update
      "$ESCALATION_TOOL" apt-get install -y --no-install-recommends $filtered_packages
      ;;
    dnf)
      "$ESCALATION_TOOL" dnf install -y --setopt=install_weak_deps=False \
        --skip-unavailable $filtered_packages
      ;;
    zypper)
      "$ESCALATION_TOOL" zypper refresh
      "$ESCALATION_TOOL" zypper --non-interactive install $filtered_packages
      ;;
    apk)
      "$ESCALATION_TOOL" apk add $filtered_packages
      ;;
    xbps-install)
      "$ESCALATION_TOOL" xbps-install -Sy $filtered_packages
      ;;
    eopkg)
      "$ESCALATION_TOOL" eopkg install -y $filtered_packages
      ;;
    *)
      printf "%b\n" "${RED}✖ Unsupported package manager: $PM${RC}"
      return 1
      ;;
  esac

  mark_done "$state_key"
}

# ── AUR Helper Setup (Arch only) ────────────────────────────────

setup_aur_helper() {
  [[ "${PM:-}" != "pacman" ]] && return 0
  [[ -n "${AUR_HELPER:-}" ]] && return 0

  printf "%b\n" "${YELLOW}⚠ No AUR helper detected (yay or paru).${RC}"
  printf "%b\n" "  AUR helper is recommended for some packages."
  echo "  1) yay (recommended)"
  echo "  2) paru"
  echo "  3) Skip"
  read -r -p "  Select [1-3]: " choice

  case "$choice" in
    1)
      if [[ -f "$ROOT_DIR/plugins/tools/yay/plugin.sh" ]]; then
          printf "%b\n" "${CYAN}📦 Installing yay via plugin...${RC}"
          (source "$ROOT_DIR/plugins/tools/yay/plugin.sh" && plugin_install)
      else
          printf "%b\n" "${CYAN}📦 Installing yay-bin from AUR...${RC}"
          "$ESCALATION_TOOL" "$PM" -S --needed --noconfirm git base-devel
          local build_dir="/tmp/yay-build-$$"
          git clone https://aur.archlinux.org/yay-bin.git "$build_dir"
          (cd "$build_dir" && makepkg -si --noconfirm)
          rm -rf "$build_dir"
      fi
      AUR_HELPER="yay"
      ;;
    2)
      if [[ -f "$ROOT_DIR/plugins/tools/paru/plugin.sh" ]]; then
          printf "%b\n" "${CYAN}📦 Installing paru via plugin...${RC}"
          (source "$ROOT_DIR/plugins/tools/paru/plugin.sh" && plugin_install)
      else
          printf "%b\n" "${CYAN}📦 Installing paru from AUR...${RC}"
          "$ESCALATION_TOOL" "$PM" -S --needed --noconfirm git base-devel
          local build_dir="/tmp/paru-build-$$"
          git clone https://aur.archlinux.org/paru.git "$build_dir"
          (cd "$build_dir" && makepkg -si --noconfirm)
          rm -rf "$build_dir"
      fi
      AUR_HELPER="paru"
      ;;
    *)
      printf "%b\n" "${DIM}⏭ Skipping AUR helper${RC}"
      ;;
  esac
  export AUR_HELPER
}

# ── Arch-specific: Enable multilib ──────────────────────────────

arch_pre_setup() {
  [[ "${PM:-}" != "pacman" ]] && return 0
  state_done arch_multilib && return 0

  if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    "$ESCALATION_TOOL" sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
    "$ESCALATION_TOOL" pacman -Syy
  fi
  mark_done arch_multilib
}

# ── Ubuntu/Debian: ncurses5 compat symlinks ─────────────────────

ubuntu_ncurses_compat() {
  [[ "${PM:-}" != "apt-get" && "${PM:-}" != "nala" ]] && return 0
  state_done ncurses5 && return 0

  local LIB="/usr/lib/x86_64-linux-gnu"
  [[ -f "$LIB/libncurses.so.6" && ! -e "$LIB/libncurses.so.5" ]] && \
    "$ESCALATION_TOOL" ln -s "$LIB/libncurses.so.6" "$LIB/libncurses.so.5"
  [[ -f "$LIB/libtinfo.so.6" && ! -e "$LIB/libtinfo.so.5" ]] && \
    "$ESCALATION_TOOL" ln -s "$LIB/libtinfo.so.6" "$LIB/libtinfo.so.5"

  mark_done ncurses5
}
