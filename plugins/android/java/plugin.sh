plugin_describe() { echo "android-java - JDK for Android builds"; }
plugin_install() { install_packages "android_java" $(pkg_java); }
