plugin_describe() { echo "ccache - CCache with optimized build settings"; }

plugin_install() {
  # ── Install ccache package ──
  if ! command_exists ccache; then
    printf "%b\n" "${CYAN}📦 Installing ccache...${RC}"
    case "$PM" in
      pacman)       $ESCALATION_TOOL $PM -S --needed --noconfirm ccache ;;
      dnf)          $ESCALATION_TOOL dnf install -y ccache ;;
      apt-get|nala) $ESCALATION_TOOL apt-get install -y ccache ;;
      zypper)       $ESCALATION_TOOL zypper --non-interactive install ccache ;;
      apk)          $ESCALATION_TOOL apk add ccache ;;
      xbps-install) $ESCALATION_TOOL xbps-install -Sy ccache ;;
      eopkg)        $ESCALATION_TOOL eopkg install -y ccache ;;
    esac
  fi

  # ── Configure ccache ──
  if ! state_done ccache_cfg; then
    printf "%b\n" "${CYAN}⚙ Configuring ccache (50 GB cache)...${RC}"
    mkdir -p "$HOME/.cache/ccache" "$HOME/.ccache"
    cat > "$HOME/.ccache/ccache.conf" <<EOF
max_size = 50G
compression = true
compiler_check = content
EOF
    ccache -z || true
    mark_done ccache_cfg
  fi

  # ── Configure ulimits for Android builds ──
  if ! state_done ulimits; then
    printf "%b\n" "${CYAN}⚙ Configuring ulimits for Android builds...${RC}"
    $ESCALATION_TOOL mkdir -p /etc/security/limits.d
    $ESCALATION_TOOL tee /etc/security/limits.d/99-android-build.conf >/dev/null <<'EOF'
* soft nofile 1048576
* hard nofile 1048576
* soft nproc  1048576
* hard nproc  1048576
* soft stack  unlimited
* hard stack  unlimited
EOF
    mark_done ulimits
  fi
}
