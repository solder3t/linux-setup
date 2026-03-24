#!/usr/bin/env bash
# ui.sh — Whiptail-based TUI with distro-aware filtering

VERSION="2.0.0"

# ── Print Environment Banner ────────────────────────────────────

print_banner() {
  local cols
  cols=$(tput cols 2>/dev/null || echo 60)
  local line
  line=$(printf '─%.0s' $(seq 1 "$cols"))

  printf "\n%b" "${CYAN}${BOLD}"
  cat <<'BANNER'
   ╦  ╦╔╗╔╦ ╦═╗ ╦   ╔═╗╔═╗╔╦╗╦ ╦╔═╗
   ║  ║║║║║ ║╔╩╦╝───╚═╗║╣  ║ ║ ║╠═╝
   ╩═╝╩╝╚╝╚═╝╩ ╚═   ╚═╝╚═╝ ╩ ╚═╝╩
BANNER
  printf "%b" "${RC}"

  printf "%b\n" "${DIM}${line}${RC}"
  printf "%b\n" "  ${BOLD}Version${RC}  ${DIM}${VERSION}${RC}"
  printf "%b\n" "  ${BOLD}Distro${RC}   ${DISTRO_NAME}"
  printf "%b\n" "  ${BOLD}Arch${RC}     ${ARCH}"
  printf "%b\n" "  ${BOLD}Pkg Mgr${RC}  ${PM}${AUR_HELPER:+ (+$AUR_HELPER)}"
  printf "%b\n" "  ${BOLD}Priv${RC}     ${ESCALATION_TOOL}${SUGROUP:+ (group: $SUGROUP)}"
  [[ -n "${INIT_MANAGER:-}" ]] && printf "%b\n" "  ${BOLD}Init${RC}     ${INIT_MANAGER}"
  printf "%b\n\n" "${DIM}${line}${RC}"
}

# ── Whiptail Plugin Selector ───────────────────────────────────

ui_select_plugins() {
  # Dark Mode Theme
  export NEWT_COLORS='
    root=,black
    window=,black
    border=cyan,black
    shadow=,black
    textbox=white,black
    button=black,cyan
    actbutton=black,white
    listbox=white,black
    actlistbox=black,cyan
    checkbox=cyan,black
    actcheckbox=black,cyan
    title=cyan,black
    compactbutton=white,black
  '

  # ── Build data structures ──
  declare -A PLUGIN_STATE
  declare -A PLUGIN_PATH_MAP
  declare -A PLUGIN_DESC_MAP
  declare -A SUPERCAT_MAP     # supercat_name → "plugin1 plugin2 ..."
  local -a supercats_order=()

  for plugin in "${PLUGINS_LOADED[@]}"; do
    local p_dir p_name c_dir dir_cat
    p_dir="$(dirname "$plugin")"
    p_name="$(basename "$p_dir")"
    c_dir="$(dirname "$p_dir")"
    dir_cat="$(basename "$c_dir")"

    [[ "$dir_cat" == "plugins" ]] && dir_cat="General"
    [[ "${dir_cat,,}" == "ide" ]] && dir_cat="IDE"
    [[ "$dir_cat" != "IDE" ]] && dir_cat="${dir_cat^}"

    # Skip unsupported plugins for this distro
    if ! is_plugin_supported "$plugin"; then
      continue
    fi

    # Map to merged super-category
    local supercat
    supercat="$(get_category_display "$dir_cat")"

    if [[ -z "${SUPERCAT_MAP[$supercat]:-}" ]]; then
       SUPERCAT_MAP["$supercat"]="$p_name"
       supercats_order+=("$supercat")
    else
       SUPERCAT_MAP["$supercat"]+=" $p_name"
    fi

    PLUGIN_STATE["$p_name"]="OFF"
    PLUGIN_PATH_MAP["$p_name"]="$plugin"
    PLUGIN_DESC_MAP["$p_name"]="$(get_plugin_description "$plugin" "$p_name")"
  done

  # Sort categories
  IFS=$'\n' supercats_order=($(printf '%s\n' "${supercats_order[@]}" | sort -u)); unset IFS

  # ── Main Loop ──
  while true; do
      local count=0
      for k in "${!PLUGIN_STATE[@]}"; do
          [[ "${PLUGIN_STATE[$k]}" == "ON" ]] && ((count+=1))
      done

      # Build main menu options
      local main_options=()
      for supercat in "${supercats_order[@]}"; do
          local c_count=0 c_total=0
          for p in ${SUPERCAT_MAP[$supercat]}; do
              ((c_total+=1))
              [[ "${PLUGIN_STATE[$p]}" == "ON" ]] && ((c_count+=1))
          done

          local label
          if [[ $c_count -gt 0 ]]; then
            label=$(printf "(%d/%d selected)" "$c_count" "$c_total")
          else
            label=$(printf "(%d available)" "$c_total")
          fi
          main_options+=("$supercat" "$label")
      done

      # Install action at bottom
      if [[ $count -gt 0 ]]; then
        main_options+=("---" "─────────────────────")
        main_options+=("INSTALL" ">>> Install $count selected <<<")
      fi
      main_options+=("Quit" ">>> Exit Linux-Setup <<<")

      # Show main menu
      local choice
      choice=$(whiptail \
        --title " Linux-Setup v${VERSION} | ${DISTRO_NAME} | ${PM}${AUR_HELPER:+ +$AUR_HELPER} " \
        --ok-button "Select" \
        --cancel-button "Quit" \
        --menu "\nSelect a category to browse plugins. Plugins are filtered for your system.\n\nTips: Press 'I' to jump to INSTALL. Press 'Q' or 'ESC' to quit." \
        22 76 12 \
        "${main_options[@]}" \
        3>&1 1>&2 2>&3) || {
          # Cancel/Esc pressed — exit immediately
          return 1
        }

      # Skip separator
      [[ "$choice" == "---" ]] && continue

      # Handle Quit
      if [[ "$choice" == "Quit" ]]; then
          return 1
      fi

      # Handle Install
      if [[ "$choice" == "INSTALL" ]]; then
          if [[ $count -eq 0 ]]; then
             whiptail --title " Warning " --msgbox "No plugins selected!" 8 40 >&2
             continue
          fi

          local confirm_text="The following $count plugin(s) will be installed:\n\n"
          for p in "${!PLUGIN_STATE[@]}"; do
             if [[ "${PLUGIN_STATE[$p]}" == "ON" ]]; then
                 confirm_text+="  • $p\n"
             fi
          done
          confirm_text+="\nProceed with installation?"

          # Calculate dynamic height (max 22)
          local box_h=$(( count + 12 ))
          if (( box_h > 22 )); then box_h=22; fi

          if whiptail --title " Confirm Installation " --yesno "$confirm_text" "$box_h" 60 >&2; then
              break
          else
              continue
          fi
      fi

      # ── Category checklist ──
      local selected_cat="$choice"
      local sub_options=()
      local plugins_in_cat
      read -ra plugins_in_cat <<<"${SUPERCAT_MAP[$selected_cat]}"

      # Sort
      IFS=$'\n' plugins_in_cat=($(sort <<<"${plugins_in_cat[*]}")); unset IFS

      for p_name in "${plugins_in_cat[@]}"; do
          local desc="${PLUGIN_DESC_MAP[$p_name]:-$p_name}"
          local stat="${PLUGIN_STATE[$p_name]}"
          sub_options+=("$p_name" "$desc" "$stat")
      done

      local sub_choices
      sub_choices=$(whiptail \
        --title " ${selected_cat} " \
        --ok-button "Save & Back" \
        --cancel-button "Discard & Back" \
        --checklist "\nSpace to toggle, Enter to save. Esc to discard changes.\n" \
        22 76 12 \
        "${sub_options[@]}" \
        3>&1 1>&2 2>&3)

      if [[ $? -eq 0 ]]; then
          # Reset this category
          for p in "${plugins_in_cat[@]}"; do
             PLUGIN_STATE[$p]="OFF"
          done
          # Set selected
          eval "arr=($sub_choices)"
          if [[ ${#arr[@]} -gt 0 ]]; then
              for sel in "${arr[@]}"; do
                  PLUGIN_STATE[$sel]="ON"
              done
          fi

          # Count total selected across all categories
          local total_sel=0
          local new_in_cat=0
          for k in "${!PLUGIN_STATE[@]}"; do
             if [[ "${PLUGIN_STATE[$k]}" == "ON" ]]; then
                 ((total_sel+=1))
                 # Check if this plugin is in the current category
                 for p in "${plugins_in_cat[@]}"; do
                     [[ "$p" == "$k" ]] && ((new_in_cat+=1))
                 done
             fi
          done

          if [[ $total_sel -gt 0 ]]; then
             if [[ $new_in_cat -eq 0 && ${#arr[@]} -eq 0 ]]; then
                 whiptail --title " Info " --msgbox "Note: You must press [Space] to select an item before pressing [Enter].\n\nYou haven't added any new packages from this category, but you still have $total_sel package(s) selected overall." 10 60 >&2
             else
                 local prompt_msg="You have $total_sel package(s) currently selected:\n\n"
                 for p in "${!PLUGIN_STATE[@]}"; do
                    if [[ "${PLUGIN_STATE[$p]}" == "ON" ]]; then
                        prompt_msg+="  • $p\n"
                    fi
                 done
                 prompt_msg+="\nDo you want to proceed with installation now?\n\nSelect <Install> to continue, or <Browse More> to go back to the menu."

                 local box_h=$(( total_sel + 12 ))
                 if (( box_h > 22 )); then box_h=22; fi

                 if whiptail --title " Install Now? " --yes-button "Install" --no-button "Browse More" --yesno "$prompt_msg" "$box_h" 60 >&2; then
                     break
                 fi
             fi
          else
             whiptail --title " Info " --msgbox "No packages selected.\n\nTip: You must press [Space] to select an item before pressing [Enter]." 10 60 >&2
          fi
      fi
      # Cancel in sub-menu → back to main (no state change)
  done

  # Return selected plugin names
  local final_list=""
  for p in "${!PLUGIN_STATE[@]}"; do
     if [[ "${PLUGIN_STATE[$p]}" == "ON" ]]; then
        final_list+="$p "
     fi
  done

  echo "$final_list"
}
