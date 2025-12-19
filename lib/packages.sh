android_packages() {
  case "$PM" in
    pacman)
      echo "base-devel git git-lfs repo wget curl bc cpio xmlto inetutils kmod lz4 zstd clang llvm lld aarch64-linux-gnu-gcc arm-none-eabi-gcc python python-mako python-protobuf python-setuptools jdk21-openjdk lib32-zlib lib32-ncurses lib32-readline lib32-gcc-libs lib32-glibc gperf sdl2 squashfs-tools pngcrush schedtool perl-switch zip unzip lzip libxslt libxml2 imagemagick rsync dtc pahole libelf android-tools android-udev ccache"
      ;;
    dnf)
      echo "git git-lfs repo gnupg flex bison gperf zip unzip curl zlib-devel libxml2 xsltproc lz4 python3 python3-mako python3-protobuf python3-pip python3-devel perl-Switch openssl-devel schedtool ImageMagick ncurses-devel ncurses-compat-libs ccache rsync java-21-openjdk-devel glibc-devel.i686 libstdc++-devel.i686 zlib-devel.i686 ncurses-devel.i686 readline-devel.i686 bc elfutils-libelf-devel dtc clang llvm lld dwarves gcc-aarch64-linux-gnu gcc-arm-linux-gnu android-tools"
      ;;
    apt)
      echo "build-essential git git-lfs gnupg flex bison gperf zip unzip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 libncurses-dev lib32ncurses-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc fontconfig imagemagick python3 python3-pip python3-mako python3-protobuf python-is-python3 rsync schedtool ccache lz4 zstd libssl-dev bc libelf-dev device-tree-compiler clang llvm lld dwarves gcc-aarch64-linux-gnu gcc-arm-linux-gnueabi openjdk-21-jdk"
      ;;
  esac
}
