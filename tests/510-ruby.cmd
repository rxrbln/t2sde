#!/bin/sh

[ "$QEMU" ] || exit 43

exe=usr/bin/ruby

[ -e $SYSROOT/$exe ] || exit 42

$QEMU -chroot $SYSROOT $exe -e 'puts "Hello Ruby."'
