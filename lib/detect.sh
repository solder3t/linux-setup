#!/usr/bin/env bash
# Detect the package manager early

detect_pm() {
  if command -v pacman >/dev/null 2>&1; then
    PM="pacman"
    if command -v paru >/dev/null 2>&1; then
      AUR_HELPER="paru"
    elif command -v yay >/dev/null 2>&1; then
      AUR_HELPER="yay"
    fi
  elif command -v dnf >/dev/null 2>&1; then
    PM="dnf"
  elif command -v apt-get >/dev/null 2>&1; then
    PM="apt"
  else
    echo "❌ Unsupported package manager"
    exit 1
  fi
  export PM
}

detect_pm
