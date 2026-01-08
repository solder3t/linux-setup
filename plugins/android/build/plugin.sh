plugin_describe() { echo "android-build - Compilers & build tools (gcc, clang, make)"; }
plugin_install() { install_packages "android_build" $(pkg_build); }
