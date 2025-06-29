#!/bin/sh

[ "$QEMU" ] || exit 43

exe=usr/bin/wine

[ -e $SYSROOT/$exe ] || exit 42

test=${0%.cmd}.exe
cp -f $test $SYSROOT/tmp/

wine=$(cd $SYSROOT; echo usr/lib*/wine/*-unix/wine)

export WINEDEBUG=-all
$QEMU -chroot $SYSROOT /$wine-preloader /$wine /tmp/${test##*/}
rm -f $SYSROOT/tmp/*.exe
