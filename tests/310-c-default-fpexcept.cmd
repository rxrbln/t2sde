#!/bin/sh

[ "$QEMU" ] || exit 43

cc=$(echo $SYSROOT/TOOLCHAIN/cross/bin/*-cc)
[ -e "$cc" ] || exit 43

cd $SYSROOT
exe=$$.exe

$cc -o $exe ${0%.cmd}.c
$QEMU -chroot $SYSROOT $exe || true
rm -f $exe
