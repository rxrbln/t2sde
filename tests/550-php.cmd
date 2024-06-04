#!/bin/sh

[ "$QEMU" ] || exit 43

exe=usr/bin/php

[ -e $SYSROOT/$exe ] || exit 42

echo '<?php
echo "Hello PHP.\n";' | $QEMU -chroot $SYSROOT $exe
