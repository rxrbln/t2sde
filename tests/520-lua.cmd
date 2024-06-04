#!/bin/sh

[ "$QEMU" ] || exit 43

exe=usr/bin/lua

[ -e $SYSROOT/$exe ] || exit 42

$QEMU -chroot $SYSROOT $exe -e 'print "Hello Lua."'
