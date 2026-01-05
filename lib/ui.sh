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
  for plugin in "${PLUGINS_LOADED[@]}"; do
    # Get plugin name from path (e.g. .../plugins/android/plugin.sh -> android)
    plugin_name="$(basename "$(dirname "$plugin")")"
    
    # Get description safely in subshell
    desc=$(
      source "$plugin"
      if declare -f plugin_describe >/dev/null; then
        plugin_describe
      else
        echo "$plugin_name"
      fi
    )

    # Clean description for display (remove potential extra formatting)
    desc="${desc//[$'\t\r\n']/ }"
    desc="${desc%%  *}" # Truncate if multiple spaces? No, just replace newlines.
    
    # If description doesn't start with name, prepend it for clarity?
    # No, whiptail shows the tag (name).
    # Maybe the issue is the sort order?
    # I'll let it be for now, just robustify the newline handling.

    # Default status: ON for everyone? Or OFF? 
    # Let's turn ON by default for now, or maybe check if it handles tags.
    status="OFF"

    options+=("$plugin_name" "$desc" "$status")
  done

  # Show checklist
  # 3>&1 1>&2 2>&3 swap needed to capture output of whiptail which goes to stderr
  local choices
  choices=$(whiptail --title "Linux Setup" \
    --checklist "Select plugins to install:" \
    20 78 10 \
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
