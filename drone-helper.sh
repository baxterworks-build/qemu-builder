#!/usr/bin/env bash
set -euf -o pipefail

STAGING=/tmp/myqemu/
WORKING=$PWD

echo "Staging is $STAGING"
echo "Working dir is $WORKING"


export CFLAGS="-Wno-stringop-truncation"
./configure --python=$(command -v python3) --cross-prefix=x86_64-w64-mingw32- --disable-docs --enable-whpx
echo 4.99.99 > VERSION
make -j`nproc` &> build-output.log

mkdir output
cp build-output.log output/

make install prefix=$STAGING

#todo: probably better to walk these dependencies in a loop, and not use grep (but seriously, where's the mingw dumpbin)

FIRST=$(strings $STAGING/*.exe | grep '\.dll' | sort -u | xargs -I{} readlink -e /usr/x86_64-w64-mingw32/sys-root/mingw/bin/{})
SECOND=$(for d in $FIRST; do strings $d | grep '\.dll' | sort -u | xargs -I{} readlink -e /usr/x86_64-w64-mingw32/sys-root/mingw/bin/{}; done)
THIRD=$(for d in $SECOND; do strings $d | grep '\.dll' | sort -u | xargs -I{} readlink -e /usr/x86_64-w64-mingw32/sys-root/mingw/bin/{}; done)
echo $FIRST $SECOND $THIRD | sed 's/ /\n/g' | sort -u | xargs -I{} cp -v {} $STAGING

pushd /tmp/myqemu/
tar -czf $WORKING/output/qemu.tar.gz .
popd

