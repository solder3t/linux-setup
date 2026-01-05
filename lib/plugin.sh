PLUGINS_LOADED=()
load_plugins() {
  for plugin in "$ROOT_DIR/plugins"/*/*/plugin.sh "$ROOT_DIR/plugins"/*/plugin.sh; do
    [[ -f "$plugin" ]] || continue
    source "$plugin"
    PLUGINS_LOADED+=("$plugin")
  done
}
run_plugin_hook() {
  local hook="$1"
  for plugin in "${PLUGINS_LOADED[@]}"; do
    grep -q "plugin_${hook}()" "$plugin" && plugin_${hook}
  done
}
