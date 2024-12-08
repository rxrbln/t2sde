#!/bin/sh

[ "$QEMU" ] || exit 43

exe=opt/mozilla/lib*/firefox/firefox

[ -e $SYSROOT/$exe ] || exit 42

cd $SYSROOT # for wildcard expansion
$QEMU -chroot $SYSROOT $exe --version
