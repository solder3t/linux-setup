plugin_describe() { echo "android-core - Basic utils (git, curl, zip)"; }
plugin_install() { install_packages "android_core" $(pkg_core); }
