#!/bin/sh

[ "$QEMU" ] || exit 43

cd $SYSROOT
exe=usr/bin/icuinfo
[ -e $exe ] || exit 42

$QEMU -chroot $SYSROOT $exe -v | grep return
