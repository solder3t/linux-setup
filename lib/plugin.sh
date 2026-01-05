PLUGINS_LOADED=()
load_plugins() {
  for plugin in "$ROOT_DIR/plugins"/*/*/plugin.sh "$ROOT_DIR/plugins"/*/plugin.sh; do
    [[ -f "$plugin" ]] || continue
    # Don't source here, just track the file
    PLUGINS_LOADED+=("$plugin")
  done
}

run_plugin_hook() {
  local hook="$1"
  for plugin in "${PLUGINS_LOADED[@]}"; do
    # Run in subshell to avoid polluting global namespace
    (
      source "$plugin"
      if declare -f "plugin_$hook" >/dev/null; then
        plugin_"$hook"
      fi
    )
  done
}

run_selected_plugins() {
  local hook="$1"; shift
  local targets=("$@")

  for plugin in "${PLUGINS_LOADED[@]}"; do
    for t in "${targets[@]}"; do
      if [[ "$plugin" == *"/$t/"* ]]; then
        (
          source "$plugin"
          if declare -f "plugin_$hook" >/dev/null; then
            plugin_"$hook"
          fi
        )
      fi
    done
  done
}

run_default_profile() {
  echo "📦 Running default linux-setup profile"
  DEFAULT=(integrations zsh ccache clang android)
  run_selected_plugins install "${DEFAULT[@]}"
}
