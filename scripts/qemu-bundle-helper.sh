#!/bin/bash

set -x
ALLDLLS=$(strings /qemu/*.exe | grep '\.dll' | sort -u | grep -Ev "(WIN|Win|WS2_32|kernel|KERNEL|SHELL|USER|ADVAPI|SETUPAPI|NETAPI|CFGMGR32|POWRPROF|WTSAPI|ole32|msvcrt|api-)" | xargs -I{} readlink -e /usr/x86_64-w64-mingw32/sys-root/mingw/bin/{})
SECOND=$(for d in $ALLDLLS; do strings $d | grep '\.dll' | sort -u | xargs -I{} readlink -e /usr/x86_64-w64-mingw32/sys-root/mingw/bin/{}; done)
echo
echo Dependencies:
echo $ALLDLLS
echo
echo $SECOND

#voltagex@debian:~/src/docker/qemu-builder/built/qemu$ grep -r iconv.dll
#grep: libintl-8.dll: binary file matches

echo $ALLDLLS $SECOND /usr/x86_64-w64-mingw32/sys-root/mingw/bin/iconv.dll | sed 's/ /\n/g' | sort -u | xargs -I{} cp -v {} /qemu/
cp /usr/src/qemu/*.log /qemu/
tar -czf /qemu.tar.gz /qemu
