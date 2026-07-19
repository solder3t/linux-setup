plugin_describe() { echo "antigravity - Google Antigravity IDE and Agent (v2.0)"; }

_antigravity_choose() {
  local prompt="$1"; shift
  local options=("$@")
  local choice
  echo >&2
  echo "$prompt" >&2
  select choice in "${options[@]}"; do
    [[ -n "$choice" ]] && echo "$choice" && return
    echo "Invalid choice, try again." >&2
  done
}

plugin_install() {
  local mode="both"
  
  if [[ "$SKIP_CONFIRMATION" != "true" && -t 0 && -t 1 ]]; then
    echo -e "\n${BOLD}Antigravity 2.0 Installation Options:${RC}"
    local options=("Antigravity 2.0 Agent (Background Hub)" "Antigravity 2.0 IDE (Standalone IDE)" "Both (Agent & IDE)")
    local choice
    choice=$(_antigravity_choose "Select component to install:" "${options[@]}")
    
    case "$choice" in
      "Antigravity 2.0 Agent (Background Hub)")
        mode="agent"
        ;;
      "Antigravity 2.0 IDE (Standalone IDE)")
        mode="ide"
        ;;
      "Both (Agent & IDE)")
        mode="both"
        ;;
    esac
  fi

  printf "%b\n" "${CYAN}📦 Installing Antigravity 2.0 ($mode) via one-liner...${RC}"
  
  if [[ "$mode" == "agent" || "$mode" == "both" ]]; then
    printf "%b\n" "${CYAN}Installing Antigravity 2.0 Agent...${RC}"
    bash <(curl -fsSL https://raw.githubusercontent.com/jssroberto/antigravity-2-fedora-installer/main/install.sh) --mode agent -y
  fi

  if [[ "$mode" == "ide" || "$mode" == "both" ]]; then
    printf "%b\n" "${CYAN}Installing Antigravity 2.0 IDE...${RC}"
    bash <(curl -fsSL https://raw.githubusercontent.com/jssroberto/antigravity-2-fedora-installer/main/install.sh) --mode ide -y
  fi
}

plugin_uninstall() {
  local mode="both"

  # Detect what is installed to prompt intelligently if interactive
  local has_agent=0
  local has_ide=0
  command_exists antigravity && has_agent=1
  command_exists antigravity-ide && has_ide=1

  if [[ $has_agent -eq 1 && $has_ide -eq 1 ]]; then
    if [[ "$SKIP_CONFIRMATION" != "true" && -t 0 && -t 1 ]]; then
      echo -e "\n${BOLD}Antigravity 2.0 Uninstallation Options:${RC}"
      local options=("Uninstall Antigravity 2.0 Agent only" "Uninstall Antigravity 2.0 IDE only" "Uninstall Both (Agent & IDE)")
      local choice
      choice=$(_antigravity_choose "Select component to uninstall:" "${options[@]}")

      case "$choice" in
        "Uninstall Antigravity 2.0 Agent only")
          mode="agent"
          ;;
        "Uninstall Antigravity 2.0 IDE only")
          mode="ide"
          ;;
        "Uninstall Both (Agent & IDE)")
          mode="both"
          ;;
      esac
    fi
  elif [[ $has_agent -eq 1 ]]; then
    mode="agent"
  elif [[ $has_ide -eq 1 ]]; then
    mode="ide"
  fi

  printf "%b\n" "${CYAN}🗑 Uninstalling Antigravity 2.0 ($mode) via one-liner...${RC}"

  if [[ "$mode" == "agent" ]]; then
    bash <(curl -fsSL https://raw.githubusercontent.com/jssroberto/antigravity-2-fedora-installer/main/uninstall.sh) --agent < /dev/null
  elif [[ "$mode" == "ide" ]]; then
    bash <(curl -fsSL https://raw.githubusercontent.com/jssroberto/antigravity-2-fedora-installer/main/uninstall.sh) --ide < /dev/null
  else
    bash <(curl -fsSL https://raw.githubusercontent.com/jssroberto/antigravity-2-fedora-installer/main/uninstall.sh) --both < /dev/null
  fi
}

plugin_installed() {
  command_exists antigravity || command_exists antigravity-ide
}
