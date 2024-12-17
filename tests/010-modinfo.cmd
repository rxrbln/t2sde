#!/bin/sh

[ "$QEMU" ] || exit 43

[ -e $SYSROOT/sbin/modinfo ] || exit 42
[ -e $SYSROOT/lib/modules/*/fs/binfmt_misc.ko ] || exit 42

cd $SYSROOT
$QEMU -chroot $SYSROOT sbin/modinfo -F name lib/modules/*-t2/fs/binfmt_misc.ko
