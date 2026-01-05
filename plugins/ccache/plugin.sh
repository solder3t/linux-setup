plugin_describe() { echo "ccache - CCache"; }
plugin_install() { configure_ccache; configure_ulimits; }
