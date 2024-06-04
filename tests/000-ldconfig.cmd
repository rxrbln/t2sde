#!/bin/sh

[ "$QEMU" ] || exit 43

[ -e $SYSROOT/sbin/ldconfig ] || exit 42

cd $SYSROOT
$QEMU -chroot $SYSROOT sbin/ldconfig
