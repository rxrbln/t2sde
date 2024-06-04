#!/bin/sh

[ "$QEMU" ] || exit 43

[ -e $SYSROOT/bin/ls ] || exit 42

$QEMU -chroot $SYSROOT bin/ls -d etc proc dev sys tmp
