pkg_core() {
  case "$PM" in
    pacman) echo "git git-lfs wget curl bc cpio xmlto inetutils kmod zip unzip lzip rsync" ;;
    dnf)    echo "git git-lfs gnupg curl zip unzip rsync bc" ;;
    apt)    echo "git git-lfs gnupg zip unzip curl rsync bc" ;;
  esac
}

pkg_build() {
  case "$PM" in
    pacman) echo "base-devel clang llvm lld aarch64-linux-gnu-gcc arm-none-eabi-gcc gperf" ;;
    dnf)    echo "flex bison gperf clang llvm lld dwarves gcc-aarch64-linux-gnu gcc-arm-linux-gnu" ;;
    apt)    echo "build-essential flex bison gperf gcc-multilib g++-multilib clang llvm lld dwarves" ;;
  esac
}

pkg_libs() {
  case "$PM" in
    pacman) echo "lib32-zlib lib32-ncurses lib32-readline lib32-gcc-libs lib32-glibc libxslt libxml2 imagemagick libelf" ;;
    dnf)    echo "zlib-devel libxml2 xsltproc openssl-devel ImageMagick ncurses-devel ncurses-compat-libs glibc-devel.i686 libstdc++-devel.i686 zlib-devel.i686 ncurses-devel.i686 readline-devel.i686 elfutils-libelf-devel" ;;
    apt)    echo "zlib1g-dev libc6-dev-i386 libncurses-dev lib32ncurses-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc fontconfig imagemagick libssl-dev libelf-dev" ;;
  esac
}

pkg_python() {
  case "$PM" in
    pacman) echo "python python-mako python-protobuf python-setuptools" ;;
    dnf)    echo "python3 python3-mako python3-protobuf python3-pip python3-devel" ;;
    apt)    echo "python3 python3-pip python3-mako python3-protobuf python-is-python3" ;;
  esac
}

pkg_java() {
  case "$PM" in
    pacman) echo "jdk21-openjdk" ;;
    dnf)    echo "java-21-openjdk-devel" ;;
    apt)    echo "openjdk-21-jdk" ;;
  esac
}

pkg_android() {
  case "$PM" in
    pacman) echo "repo sdl2 squashfs-tools pngcrush schedtool perl-switch dtc pahole android-tools android-udev ccache lz4 zstd" ;;
    dnf)    echo "repo perl-Switch schedtool ccache lz4 dtc android-tools" ;;
    apt)    echo "schedtool ccache lz4 zstd device-tree-compiler" ;;
  esac
}

android_packages() {
  # Concatenate all categories
  echo "$(pkg_core) $(pkg_build) $(pkg_libs) $(pkg_python) $(pkg_java) $(pkg_android)"
}
