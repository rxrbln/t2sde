#!/bin/sh

[ "$QEMU" ] || exit 43

[ -e $SYSROOT/bin/sh ] || exit 42

$QEMU -chroot $SYSROOT bin/bash -c "for i in 1 2 a b; do echo \$i; done"
