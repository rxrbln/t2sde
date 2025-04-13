#!/bin/sh

[ "$QEMU" ] || exit 43

cd $SYSROOT
exe=usr/bin/svn
[ -e $exe ] || exit 42

LANG=C $QEMU -chroot $SYSROOT $exe st usr/src/t2-src
