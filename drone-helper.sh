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
echo 5.99.99 > VERSION
JOBS=${JOBS:=$(nproc)} #if we don't pass a JOBS variable in, use the value of nproc 
echo Number of jobs set to $JOBS!

time make -j$JOBS &> build-output.log

mkdir output
cp build-output.log output/

make install 

find / | gzip -3 > find.txt.gz
curl --connect-timeout 5 --user upload:$UPLOAD_AUTH -F "file=@find.txt.gz" https://droneupload.baxter.works || echo "Didn't upload to secondary upload host"

#todo: probably better to walk these dependencies in a loop, and not use grep (but seriously, where's the mingw dumpbin)
#Run the "same" command multiple times to find dependencies of dependencies
FIRST=$(strings /qemu/*.exe | grep '\.dll' | sort -u | xargs -I{} readlink -e /usr/x86_64-w64-mingw32/sys-root/mingw/bin/{})
SECOND=$(for d in $FIRST; do strings $d | grep '\.dll' | sort -u | xargs -I{} readlink -e /usr/x86_64-w64-mingw32/sys-root/mingw/bin/{}; done)
THIRD=$(for d in $SECOND; do strings $d | grep '\.dll' | sort -u | xargs -I{} readlink -e /usr/x86_64-w64-mingw32/sys-root/mingw/bin/{}; done)
echo $FIRST $SECOND $THIRD | sed 's/ /\n/g' | sort -u | xargs -I{} cp -v {} /qemu/                    

pushd /qemu/
#I am assuming anyone after qemu on Windows also has a way of extracting tar.gz
tar -czf /output/qemu.tar.gz .


