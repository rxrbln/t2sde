#!/bin/sh

[ "$QEMU" ] || exit 43

cd $SYSROOT
[ -e usr/bin/objdump -a -e bin/ls ] || exit 42

$QEMU -chroot $SYSROOT usr/bin/objdump -j .text -D bin/sh
