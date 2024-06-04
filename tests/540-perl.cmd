#!/bin/sh

[ "$QEMU" ] || exit 43

exe=usr/bin/perl

[ -e $SYSROOT/$exe ] || exit 42

# TODO: get rid of this HACK!
[ -e $SYSROOT/dev/null ] || mknod $SYSROOT/dev/null c 1 3
export LANG=C

$QEMU -chroot $SYSROOT $exe -e 'print "Hello Perl.\n";'
