#!/usr/bin/env bash
# packages.sh — Package name mappings per package manager
#
# Each function echoes a space-separated list of packages
# for the detected PM. These are primarily used by Android
# build plugins but are available to any plugin.

pkg_core() {
  case "$PM" in
    pacman)       echo "git git-lfs wget curl bc cpio xmlto inetutils kmod zip unzip lzip rsync" ;;
    dnf)          echo "git git-lfs gnupg curl zip unzip rsync bc" ;;
    apt-get|nala) echo "git git-lfs gnupg zip unzip curl rsync bc" ;;
    zypper)       echo "git git-lfs curl zip unzip rsync bc" ;;
    apk)          echo "git git-lfs curl zip unzip rsync bc" ;;
    xbps-install) echo "git git-lfs curl zip unzip rsync bc" ;;
    eopkg)        echo "git curl zip unzip rsync bc" ;;
    *)            printf "%b\n" "${YELLOW}⚠ pkg_core: unknown PM '$PM'${RC}" >&2; echo "git curl zip unzip" ;;
  esac
}

pkg_build() {
  case "$PM" in
    pacman)       echo "base-devel clang llvm lld aarch64-linux-gnu-gcc arm-none-eabi-gcc gperf" ;;
    dnf)          echo "flex bison gperf clang llvm lld dwarves gcc-aarch64-linux-gnu gcc-arm-linux-gnu" ;;
    apt-get|nala) echo "build-essential flex bison gperf gcc-multilib g++-multilib clang llvm lld dwarves" ;;
    zypper)       echo "patterns-devel-base-devel_basis clang llvm lld gperf" ;;
    apk)          echo "build-base clang llvm lld gperf" ;;
    xbps-install) echo "base-devel clang llvm lld gperf" ;;
    eopkg)        echo "-c system.devel clang llvm lld gperf" ;;
    *)            printf "%b\n" "${YELLOW}⚠ pkg_build: unknown PM '$PM'${RC}" >&2 ;;
  esac
}

pkg_libs() {
  case "$PM" in
    pacman)       echo "lib32-zlib lib32-ncurses lib32-readline lib32-gcc-libs lib32-glibc libxslt libxml2 imagemagick libelf fontconfig" ;;
    dnf)          echo "zlib-devel libxml2 xsltproc openssl-devel ImageMagick ncurses-devel ncurses-compat-libs glibc-devel.i686 libstdc++-devel.i686 zlib-devel.i686 ncurses-devel.i686 readline-devel.i686 elfutils-libelf-devel fontconfig" ;;
    apt-get|nala) echo "zlib1g-dev libc6-dev-i386 libncurses-dev lib32ncurses-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc fontconfig imagemagick libssl-dev libelf-dev" ;;
    zypper)       echo "zlib-devel libxml2-devel libxslt-devel ImageMagick fontconfig-devel libelf-devel" ;;
    apk)          echo "zlib-dev libxml2-dev libxslt-dev imagemagick fontconfig-dev elfutils-dev" ;;
    xbps-install) echo "zlib-devel libxml2-devel libxslt-devel ImageMagick fontconfig-devel elfutils" ;;
    *)            printf "%b\n" "${YELLOW}⚠ pkg_libs: unknown PM '$PM'${RC}" >&2 ;;
  esac
}

pkg_python() {
  case "$PM" in
    pacman)       echo "python python-mako python-protobuf python-setuptools" ;;
    dnf)          echo "python3 python3-mako python3-protobuf python3-pip python3-devel" ;;
    apt-get|nala) echo "python3 python3-pip python3-mako python3-protobuf python-is-python3" ;;
    zypper)       echo "python3 python3-Mako python3-protobuf python3-pip" ;;
    apk)          echo "python3 py3-pip py3-mako py3-protobuf" ;;
    xbps-install) echo "python3 python3-pip python3-Mako" ;;
    eopkg)        echo "python3 pip python3-mako" ;;
    *)            printf "%b\n" "${YELLOW}⚠ pkg_python: unknown PM '$PM'${RC}" >&2 ;;
  esac
}

pkg_java() {
  case "$PM" in
    pacman)       echo "jdk21-openjdk" ;;
    dnf)          echo "java-21-openjdk-devel" ;;
    apt-get|nala) echo "openjdk-21-jdk" ;;
    zypper)       echo "java-21-openjdk-devel" ;;
    apk)          echo "openjdk21" ;;
    xbps-install) echo "openjdk21" ;;
    eopkg)        echo "openjdk-21" ;;
    *)            printf "%b\n" "${YELLOW}⚠ pkg_java: unknown PM '$PM'${RC}" >&2 ;;
  esac
}

pkg_android() {
  case "$PM" in
    pacman)       echo "repo sdl2 squashfs-tools pngcrush schedtool perl-switch dtc pahole android-tools android-udev ccache lz4 zstd" ;;
    dnf)          echo "repo perl-Switch schedtool ccache lz4 dtc android-tools" ;;
    apt-get|nala) echo "schedtool ccache lz4 zstd device-tree-compiler" ;;
    zypper)       echo "ccache lz4 zstd dtc" ;;
    apk)          echo "ccache lz4 zstd dtc" ;;
    xbps-install) echo "ccache lz4 zstd dtc" ;;
    eopkg)        echo "ccache lz4 dtc" ;;
    *)            printf "%b\n" "${YELLOW}⚠ pkg_android: unknown PM '$PM'${RC}" >&2 ;;
  esac
}

android_packages() {
  echo "$(pkg_core) $(pkg_build) $(pkg_libs) $(pkg_python) $(pkg_java) $(pkg_android)"
}
