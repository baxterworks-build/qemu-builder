#!/usr/bin/env bash -x

#targets
#aarch64-softmmu alpha-softmmu
#arm-softmmu avr-softmmu cris-softmmu hppa-softmmu
#i386-softmmu lm32-softmmu m68k-softmmu
#microblaze-softmmu microblazeel-softmmu mips-softmmu
#mips64-softmmu mips64el-softmmu mipsel-softmmu
#moxie-softmmu nios2-softmmu or1k-softmmu ppc-softmmu
#ppc64-softmmu riscv32-softmmu riscv64-softmmu
#rx-softmmu s390x-softmmu sh4-softmmu sh4eb-softmmu
#sparc-softmmu sparc64-softmmu tricore-softmmu
#unicore32-softmmu x86_64-softmmu xtensa-softmmu
#xtensaeb-softmmu
mkdir -p /qemu/


function handle_error {
	find . -name "*.log" | xargs -i cp -vr {} /qemu/
}

ENABLED_TARGETS="aarch64-softmmu,arm-softmmu,i386-softmmu,x86_64-softmmu,ppc-softmmu"
./configure --python=$(command -v python3) --cross-prefix=x86_64-w64-mingw32- --disable-docs --enable-whpx --target-list=$ENABLED_TARGETS --bindir=/qemu --enable-slirp --enable-vhdx --enable-zstd --enable-libusb --enable-avx2 | tee qemu-configure.log || handle_error

# --enable-spice --enable-spice-protocol - there's no mingw64 spice-server?
# --enable-libssh
# git://git.libssh.org/projects/libssh.git
# https://lists.gnu.org/archive/html/qemu-devel/2019-06/msg02758.html
# no mingw64 version of cyrus-sasl-devel?
#18 4.601 ../meson.build:1566:2: ERROR: C header 'sasl/sasl.h' not found

JOBS=${JOBS:=$(nproc)} #if we don't pass a JOBS variable in, use the value of nproc
echo Number of jobs set to $JOBS!

time make -j$JOBS &> build-output.log
echo "make is done"
make install 2>&1 | tee install-output.log
echo "make install is done"

