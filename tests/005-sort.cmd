#!/bin/sh

[ "$QEMU" ] || exit 43

[ -e $SYSROOT/bin/sort ] || exit 42

printf 'car,(20)\njeep,[10]\ntruck,(5)\nbus,[3]' | $QEMU -chroot $SYSROOT bin/sort -t, -k2.2,2n
