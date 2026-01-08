plugin_describe() { echo "android-tools - Repo, adb, schedtool, etc."; }
plugin_install() { install_packages "android_tools" $(pkg_android); }
