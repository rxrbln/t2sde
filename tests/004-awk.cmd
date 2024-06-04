#!/bin/sh

[ "$QEMU" ] || exit 43

[ -e $SYSROOT/bin/sh ] || exit 42

echo "1
2
3
4" |
$QEMU -chroot $SYSROOT bin/awk '{ sum += $1 }; END { print sum }' 
