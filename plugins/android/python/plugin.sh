plugin_describe() { echo "android-python - Python build dependencies"; }
plugin_install() { install_packages "android_python" $(pkg_python); }
