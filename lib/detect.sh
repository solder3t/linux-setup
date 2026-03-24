#!/usr/bin/env bash
# detect.sh — Comprehensive environment detection
# Patterns adapted from ChrisTitusTech/linutil (MIT License)

# ── ANSI Colors (available globally) ─────────────────────────────
RC='\033[0m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
CYAN='\033[36m'
BOLD='\033[1m'
DIM='\033[2m'

# ── Helpers ──────────────────────────────────────────────────────

command_exists() {
  for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 || return 1
  done
  return 0
}

# ── Distro Detection (/etc/os-release) ───────────────────────────

detect_distro() {
  DISTRO_ID="unknown"
  DISTRO_NAME="Unknown Linux"
  DISTRO_VERSION=""
  DISTRO_ID_LIKE=""

  if [[ -f /etc/os-release ]]; then
    # shellcheck source=/dev/null
    source /etc/os-release
    DISTRO_ID="${ID:-unknown}"
    DISTRO_NAME="${PRETTY_NAME:-${NAME:-Unknown Linux}}"
    DISTRO_VERSION="${VERSION_ID:-}"
    DISTRO_ID_LIKE="${ID_LIKE:-}"
  elif [[ -f /etc/lsb-release ]]; then
    # shellcheck source=/dev/null
    source /etc/lsb-release
    DISTRO_ID="${DISTRIB_ID,,}"
    DISTRO_NAME="${DISTRIB_DESCRIPTION:-${DISTRIB_ID}}"
    DISTRO_VERSION="${DISTRIB_RELEASE:-}"
  fi

  export DISTRO_ID DISTRO_NAME DISTRO_VERSION DISTRO_ID_LIKE
}

# ── Architecture Detection ───────────────────────────────────────

detect_arch() {
  case "$(uname -m)" in
    x86_64|amd64)  ARCH="x86_64"  ;;
    aarch64|arm64) ARCH="aarch64" ;;
    armv7l)        ARCH="armv7l"  ;;
    *)
      printf "%b\n" "${RED}✖ Unsupported architecture: $(uname -m)${RC}"
      exit 1
      ;;
  esac
  export ARCH
}

# ── Privilege Escalation Tool ────────────────────────────────────

detect_escalation() {
  if [[ "$(id -u)" -eq 0 ]]; then
    ESCALATION_TOOL="eval"
    printf "%b\n" "${DIM}  Running as root, no escalation needed${RC}"
    export ESCALATION_TOOL
    return 0
  fi

  for tool in sudo doas; do
    if command_exists "$tool"; then
      ESCALATION_TOOL="$tool"
      export ESCALATION_TOOL
      return 0
    fi
  done

  printf "%b\n" "${RED}✖ No privilege escalation tool found (sudo or doas required)${RC}"
  exit 1
}

# ── Package Manager Detection ────────────────────────────────────

detect_pm() {
  # Ordered by specificity — nala before apt-get, etc.
  for pgm in pacman nala apt-get dnf zypper apk xbps-install eopkg; do
    if command_exists "$pgm"; then
      PM="$pgm"
      break
    fi
  done

  if [[ -z "${PM:-}" ]]; then
    printf "%b\n" "${RED}✖ No supported package manager found${RC}"
    exit 1
  fi

  # Enable apk community repos if needed
  if [[ "$PM" == "apk" ]] && grep -qE '^#.*community' /etc/apk/repositories 2>/dev/null; then
    "$ESCALATION_TOOL" sed -i '/community/s/^#//' /etc/apk/repositories
    "$ESCALATION_TOOL" apk update
  fi

  export PM
}

# ── AUR Helper Detection (Arch only) ────────────────────────────

detect_aur_helper() {
  [[ "${PM:-}" != "pacman" ]] && return 0

  AUR_HELPER=""
  for helper in paru yay; do
    if command_exists "$helper"; then
      AUR_HELPER="$helper"
      return 0
    fi
  done

  export AUR_HELPER
}

# ── Superuser Group Detection ───────────────────────────────────

detect_superuser() {
  SUGROUP=""
  for sug in wheel sudo root; do
    if groups 2>/dev/null | grep -qw "$sug"; then
      SUGROUP="$sug"
      break
    fi
  done

  if [[ -z "$SUGROUP" && "$(id -u)" -ne 0 ]]; then
    printf "%b\n" "${YELLOW}⚠ User is not in a known superuser group (wheel/sudo/root)${RC}"
  fi

  export SUGROUP
}

# ── Init System Detection ───────────────────────────────────────

detect_init() {
  INIT_MANAGER=""
  for manager in systemctl rc-service sv; do
    if command_exists "$manager"; then
      INIT_MANAGER="$manager"
      break
    fi
  done
  export INIT_MANAGER
}

# ── Combined Environment Check ──────────────────────────────────

detect_env() {
  detect_distro
  detect_arch
  detect_escalation
  detect_pm
  detect_aur_helper
  detect_superuser
  detect_init
}

# Auto-run on source
detect_env
