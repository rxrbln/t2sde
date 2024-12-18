#!/bin/sh

[ "$QEMU" ] || exit 43

cd $SYSROOT
[ -e usr/bin/file -a -e etc/fstab ] || exit 42

$QEMU -chroot $SYSROOT usr/bin/file -b TOOLCHAIN/pkgs/file-*.tar.zst
