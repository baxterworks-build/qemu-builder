#!/usr/bin/env bash
set -euf -o pipefail

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

ENABLED_TARGETS="aarch64-softmmu,arm-softmmu,i386-softmmu,x86_64-softmmu"
./configure --python=$(command -v python3) --cross-prefix=x86_64-w64-mingw32- --disable-docs --enable-whpx --target-list=$ENABLED_TARGETS

JOBS=${JOBS:=$(nproc)} #if we don't pass a JOBS variable in, use the value of nproc 
echo Number of jobs set to $JOBS!

mkdir -p /qemu/
time make -j$JOBS &> /qemu/build-output.log
echo "make is done"
make install &> /qemu/install-output.log
echo "make install is done"
tar -czf /qemu.tar.gz /qemu
curl --connect-timeout 5 --user upload:$UPLOAD_AUTH -F "file=@/qemu.tar.gz" https://droneupload.baxter.works || echo "Didn't upload to secondary upload host"

#This call to strings fails, but only on the CI server, so we'll do it another way
#FIRST=$(strings /qemu/*.exe | grep '\.dll' | sort -u | xargs -I{} readlink -e /usr/x86_64-w64-mingw32/sys-root/mingw/bin/{})
ALLDLLS=$(find -iname '*.exe' | xargs realpath | xargs strings | grep '\.dll' | sort -u | xargs -I{} readlink -e /usr/x86_64-w64-mingw32/sys-root/mingw/bin/{})
SECOND=$(for d in $ALLDLLS; do strings $d | grep '\.dll' | sort -u | xargs -I{} readlink -e /usr/x86_64-w64-mingw32/sys-root/mingw/bin/{}; done)
echo
echo Dependencies:
echo $ALLDLLS
echo
echo $SECOND

echo $ALLDLLS $SECOND | sed 's/ /\n/g' | sort -u | xargs -I{} cp -v {} /qemu/                    



