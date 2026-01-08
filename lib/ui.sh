ui_select_plugins() {
  local options=()
  local desc
  local plugin_name
  local status
  local status

  # Custom Whiptail Theme (Blue/Cyan/Black)
  export NEWT_COLORS='
    root=,blue
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

  # Gather plugins and descriptions
  local temp_list=()
  
  for plugin in "${PLUGINS_LOADED[@]}"; do
    plugin_name="$(basename "$(dirname "$plugin")")"
    
    
    desc=$(
      source "$plugin"
      if declare -f plugin_describe >/dev/null; then
        plugin_describe
      else
        echo "$plugin_name"
      fi
    )
    
    # Clean description: remove newlines and tabs
    desc="${desc//[$'\t\r\n']/ }"
    
    # Remove "pluginname -" prefix if present (case insensitive-ish)
    # e.g. "neovim - Text editor" -> "Text editor"
    # We use a regex match or simple substitution
    if [[ "$desc" == "$plugin_name - "* ]]; then
        desc="${desc#"$plugin_name - "}"
    elif [[ "$desc" == "$plugin_name "* ]]; then
        desc="${desc#"$plugin_name "}"
    fi

    desc="${desc%%  *}"
    
    # Store as "name|desc" for sorting
    temp_list+=("$plugin_name|$desc")
  done

  # Sort by name
  IFS=$'\n' sorted_list=($(sort <<<"${temp_list[*]}"))
  unset IFS

  # Build options array for whiptail
  for item in "${sorted_list[@]}"; do
      p_name="${item%%|*}"
      p_desc="${item#*|}"
      options+=("$p_name" "$p_desc" "OFF")
  done

  # Show checklist
  # 3>&1 1>&2 2>&3 swap needed to capture output of whiptail which goes to stderr
  local choices
  choices=$(whiptail --title "Linux Setup" \
    --checklist "Select plugins to install:\n(Press 'Space' to select/deselect, 'Enter' to confirm)" \
    22 78 12 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)

  # Check if user cancelled
  if [[ $? -ne 0 ]]; then
    echo "❌ Selection cancelled."
    return 1
  fi

  # Whiptail returns quoted strings like "android" "zsh". Clean them up.
  # We can't return arrays easily from functions in bash without globals or declare -n (bash 4.3+).
  # We'll just print them and let caller capture.
  echo "$choices" | tr -d '"'
}
