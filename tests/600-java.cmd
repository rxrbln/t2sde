#!/bin/sh

[ "$QEMU" ] || exit 43

exe=opt/java/bin/java

[ -e $SYSROOT/$exe ] || exit 42

cp -f ${0%.cmd}.jar $SYSROOT/tmp/jar
$QEMU -chroot $SYSROOT $exe -jar tmp/jar
rm -f $SYSROOT/tmp/jar
