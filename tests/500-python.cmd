#!/bin/sh

[ "$QEMU" ] || exit 43

exe=usr/bin/python

[ -e $SYSROOT/$exe ] || exit 42

$QEMU -chroot $SYSROOT $exe -c 'print ("Hello Python.");'
