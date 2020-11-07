#!/usr/bin/env bash
#set -euf -o pipefail It's temporary, I swear

STAGING=/tmp/myqemu/
WORKING=$PWD

#https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
if [ -z ${DRONE+x} ]; then 
    echo "Not running in Drone?"
    #todo: don't assume we're on Fedora
    echo fastestmirror=1 >> /etc/dnf/dnf.conf
    dnf -v install --assumeyes git make mingw64-gcc mingw64-binutils binutils findutils flex bison mingw64-pkg-config perl-podlators texinfo  \
    mingw64-glib2 mingw64-pixman mingw64-SDL2 mingw64-gettext \
    mingw64-curl mingw64-libpng mingw64-libjpeg-turbo \
    mingw64-libgcrypt mingw64-gnutls mingw64-bzip2 mingw64-libssh2 mingw64-libxml2 p7zip p7zip-plugins gcc mingw32-nsis mingw32-nsiswrapper bzip2 wget && dnf clean all

    cd /usr/src
    #Get WHPX headers
    git clone --depth=1 https://github.com/baxterworks-build/qemu-builder-builder
    cp qemu-builder-builder/headers/* /usr/x86_64-w64-mingw32/sys-root/mingw/include/
    time git clone --recursive https://github.com/qemu/qemu/
    cd qemu
    WORKING=$PWD
fi

echo "Staging is $STAGING"
echo "Working dir is $WORKING"

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

git apply whpx_case_sensitive.diff

ENABLED_TARGETS="aarch64-softmmu,arm-softmmu,i386-softmmu,x86_64-softmmu"
./configure --python=$(command -v python3) --cross-prefix=x86_64-w64-mingw32- --disable-docs --enable-whpx --target-list=$ENABLED_TARGETS
echo 5.99.99 > VERSION
JOBS=${JOBS:=$(nproc)} #if we don't pass a JOBS variable in, use the value of nproc 
echo Number of jobs set to $JOBS!

time make -j$JOBS &> build-output.log

mkdir output
cp build-output.log output/

make install prefix=$STAGING

#todo: probably better to walk these dependencies in a loop, and not use grep (but seriously, where's the mingw dumpbin)
#Run the "same" command multiple times to find dependencies of dependencies
FIRST=$(strings $STAGING/*.exe | grep '\.dll' | sort -u | xargs -I{} readlink -e /usr/x86_64-w64-mingw32/sys-root/mingw/bin/{})
SECOND=$(for d in $FIRST; do strings $d | grep '\.dll' | sort -u | xargs -I{} readlink -e /usr/x86_64-w64-mingw32/sys-root/mingw/bin/{}; done)
THIRD=$(for d in $SECOND; do strings $d | grep '\.dll' | sort -u | xargs -I{} readlink -e /usr/x86_64-w64-mingw32/sys-root/mingw/bin/{}; done)
echo $FIRST $SECOND $THIRD | sed 's/ /\n/g' | sort -u | xargs -I{} cp -v {} $STAGING

pushd /tmp/myqemu/
#I am assuming anyone after qemu on Windows also has a way of extracting tar.gz
tar -czf /output/qemu.tar.gz .


