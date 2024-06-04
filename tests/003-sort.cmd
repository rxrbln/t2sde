#!/bin/sh

[ "$QEMU" ] || exit 43

[ -e $SYSROOT/bin/sh ] || exit 42

echo "z
y
x
z
1
3
2
1" | $QEMU -chroot $SYSROOT bin/sort -u
