ui_select_plugins() {
  # Custom Whiptail Theme (Dark Mode)
  export NEWT_COLORS='
    root=,black
    window=,black
    border=cyan,black
    textbox=white,black
    button=black,cyan
    listbox=white,black
    actlistbox=black,cyan
    checkbox=cyan,black
    actcheckbox=black,cyan
    title=cyan,black
  '

  # 1. Initialize State
  declare -A PLUGIN_STATE
  declare -A CAT_MAP
  local categories_order=()
  
  # Map to store which plugins belong to which category
  # Format: CAT_MAP["Category"]="plugin1 plugin2 ..."
  
  # Temporary arrays for sorting
  local temp_cats=()
  
  for plugin in "${PLUGINS_LOADED[@]}"; do
    # Extract info
    local p_dir="$(dirname "$plugin")"
    local p_name="$(basename "$p_dir")"
    local c_dir="$(dirname "$p_dir")"
    local cat="$(basename "$c_dir")"
    
    # Normalize category
    [[ "$cat" == "plugins" ]] && cat="General"
    [[ "${cat,,}" == "ide" ]] && cat="IDE"
    [[ "$cat" != "IDE" ]] && cat="${cat^}"
    
    # Add to category map (space delimited)
    if [[ -z "${CAT_MAP[$cat]:-}" ]]; then
       CAT_MAP[$cat]="$p_name"
       temp_cats+=("$cat")
    else
       CAT_MAP[$cat]+=" $p_name"
    fi
    
    # Default state is OFF
    PLUGIN_STATE["$p_name"]="OFF"
  done
  
  # Sort unique categories
  IFS=$'\n' categories_order=($(sort -u <<<"${temp_cats[*]}")); unset IFS

  # 2. Main Event Loop
  while true; do
      # Calculate total selected
      local count=0
      for k in "${!PLUGIN_STATE[@]}"; do
          [[ "${PLUGIN_STATE[$k]}" == "ON" ]] && ((count++))
      done
      
      # Build Main Menu Options
      local main_options=()
      for cat in "${categories_order[@]}"; do
          # Count selected in this cat
          local c_count=0
          local c_total=0
          for p in ${CAT_MAP[$cat]}; do
              ((c_total++))
              [[ "${PLUGIN_STATE[$p]}" == "ON" ]] && ((c_count++))
          done
          
          # Display: "       [2/5]" (Stats only, whiptail shows tag on left)
          local label=$(printf "[%d/%d]" "$c_count" "$c_total")
          main_options+=("$cat" "$label")
      done
      
      # Add "Proceed" Action
      local install_label="Install ($count selected)"
      
      # Show Main Menu
      # Using --menu to mimic sidebar selection
      local choice
      choice=$(whiptail --title "Linux Setup - Dashboard" \
                        --menu "Select a category to explore plugins:\n(Navigate with Arrow Keys, Enter to Select)" \
                        20 60 10 \
                        "${main_options[@]}" \
                        "PROCEED" ">> $install_label <<" \
                        3>&1 1>&2 2>&3)
      
      # Helper: Handle Cancel/Exit
      if [[ $? -ne 0 ]]; then
          # If they cancel the main menu, confirm exit?
          if whiptail --yesno "Quit installation setup?" 8 40; then
             return 1
          else
             continue
          fi
      fi
      
      if [[ "$choice" == "PROCEED" ]]; then
          if [[ $count -eq 0 ]]; then
             whiptail --msgbox "No plugins selected!" 8 40
             continue
          fi
          break
      fi
      
      # 3. Sub-Menu (Checklist) for selected Category
      local selected_cat="$choice"
      local sub_options=()
      
      # Gather plugins for this category
      local plugins_in_cat=(${CAT_MAP[$selected_cat]})
      
      # Sort plugins by name
      IFS=$'\n' plugins_in_cat=($(sort <<<"${plugins_in_cat[*]}")); unset IFS
      
      for p_name in "${plugins_in_cat[@]}"; do
          # Re-resolve description (a bit expensive but safe)
          # We need to find the path again.
          # Optimization: We could have stored path in a map too.
          # For now, fast loop scan:
          local p_path=""
          for path in "${PLUGINS_LOADED[@]}"; do
             if [[ "$path" == *"/$p_name/plugin.sh" ]]; then
                p_path="$path"
                break
             fi
          done
          
          local desc=""
          if [[ -n "$p_path" ]]; then
             desc=$(source "$p_path" && declare -f plugin_describe >/dev/null && plugin_describe || echo "$p_name")
          fi
          
          # Polish Desc
          desc="${desc//[$'\t\r\n']/ }"
          if [[ "$desc" == *"$p_name - "* ]]; then desc="${desc#"$p_name - "}"; fi
          local lower_cat="${selected_cat,,}"
          if [[ "$desc" == *"$lower_cat-$p_name - "* ]]; then desc="${desc#"$lower_cat-$p_name - "}"; fi
          
          local first="${desc:0:1}"
          desc="${first^}${desc:1}"
          
          # Current status
          local stat="${PLUGIN_STATE[$p_name]}"
          
          sub_options+=("$p_name" "$desc" "$stat")
      done
      
      # Show Checklist
      local sub_choices
      sub_choices=$(whiptail --title "$selected_cat Plugins" \
                             --checklist "Select plugins to install:" \
                             22 76 12 \
                             "${sub_options[@]}" \
                             3>&1 1>&2 2>&3)
                             
      local sub_exit=$?
      
      if [[ $sub_exit -eq 0 ]]; then
          # Update State based on result
          # Result is '"foo" "bar"'
          
          # First, set all in this category to OFF (reset)
          for p in "${plugins_in_cat[@]}"; do
             PLUGIN_STATE[$p]="OFF"
          done
          
          # Enable strings returned
          eval "arr=($sub_choices)"
          for sel in "${arr[@]}"; do
              PLUGIN_STATE[$sel]="ON"
          done
      fi
      # If cancelled (ESC), we just go back to main menu without changes
  done
  
  # 4. Return Final Selection
  local final_list=""
  for p in "${!PLUGIN_STATE[@]}"; do
     if [[ "${PLUGIN_STATE[$p]}" == "ON" ]]; then
        final_list+="$p "
     fi
  done
  
  echo "$final_list"
}
