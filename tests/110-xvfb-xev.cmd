#!/bin/bash

[ "$QEMU" ] || exit 42

# TODO: uniq DISPLAY, timing?
export DISPLAY=:667
Xvfb $DISPLAY -screen 0 640x480x16 &
$QEMU -chroot $SYSROOT usr/X11/bin/xev >/dev/null 2>&1 &
sleep 1
import -window root -crop 24x24-0+0 -compress none pnm:-

kill %2
kill %1
