#!/bin/sh

[ "$QEMU" ] || exit 43

[ -e $SYSROOT/usr/bin/rsync ] || exit 42

$QEMU -chroot $SYSROOT usr/bin/rsync /media/ /mnt/
