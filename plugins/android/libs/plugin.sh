plugin_describe() { echo "android-libs - System libraries (ncurses, zlib, 32-bit libs)"; }
plugin_install() { install_packages "android_libs" $(pkg_libs); }
