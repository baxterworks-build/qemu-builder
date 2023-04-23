#!/bin/bash

set -x
ls /qemu
#FIRST=$(strings /qemu/*.exe | grep '\.dll' | sort -u | xargs -I{} readlink -e /usr/x86_64-w64-mingw32/sys-root/mingw/bin/{})
ALLDLLS=$(find -iname '/qemu/*.exe' | xargs realpath | xargs strings | grep '\.dll' | sort -u | xargs -I{} readlink -e /usr/x86_64-w64-mingw32/sys-root/mingw/bin/{})
SECOND=$(for d in $ALLDLLS; do strings $d | grep '\.dll' | sort -u | xargs -I{} readlink -e /usr/x86_64-w64-mingw32/sys-root/mingw/bin/{}; done)
echo
echo Dependencies:
echo $ALLDLLS
echo
echo $SECOND

echo $ALLDLLS $SECOND | sed 's/ /\n/g' | sort -u | xargs -I{} cp -v {} /qemu/
find /usr/src/qemu -iname '*.log' | xargs -I{} cp -v {} /qemu/
tar -czf /qemu.tar.gz /qemu
