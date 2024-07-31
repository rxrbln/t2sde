#!/bin/sh

[ "$QEMU" ] || exit 43

exe=usr/bin/qemu-riscv32

[ -e $SYSROOT/$exe ] || exit 42

$QEMU -L $SYSROOT $SYSROOT/$exe ${0%.cmd}.exe
