#!/bin/sh

# NOT NEEDED due to meson subprojects download / https://gitlab.com/qemu-project/qemu/-/commit/0abe33c13adb0ef67bfbbdce30dc5d9735899906
# kept for reference
exit 1
pushd /usr/src
git clone --depth=1 https://gitlab.freedesktop.org/slirp/libslirp
pushd /usr/src/libslirp
meson --cross-file /usr/share/mingw/toolchain-mingw64.meson \
        --default-library shared \
        --prefix /usr/x86_64-w64-mingw32/sys-root/mingw \
        --bindir /usr/x86_64-w64-mingw32/sys-root/mingw/bin \
        --sbindir /usr/x86_64-w64-mingw32/sys-root/mingw/sbin \
        --sysconfdir /usr/x86_64-w64-mingw32/sys-root/mingw/etc \
        --datadir /usr/x86_64-w64-mingw32/sys-root/mingw/share \
        --includedir /usr/x86_64-w64-mingw32/sys-root/mingw/include \
        --libdir /usr/x86_64-w64-mingw32/sys-root/mingw/lib \
        --libexecdir /usr/x86_64-w64-mingw32/sys-root/mingw/libexec \
        --localstatedir /usr/x86_64-w64-mingw32/sys-root/mingw/var \
        --sharedstatedir /usr/x86_64-w64-mingw32/sys-root/mingw/com \
        --mandir /usr/x86_64-w64-mingw32/sys-root/mingw/share/man \
        --infodir /usr/x86_64-w64-mingw32/sys-root/mingw/share/info \
		build
ninja -C build install
popd
