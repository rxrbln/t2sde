#!/bin/sh

source ${0%/*}/qemu.in

[ "$isoboot" ] || exit 43

cd $SYSROOT
expect -f ${0%.cmd}.exp $QEMUSYS $qemuargs -m $normmem ${extstorage}$ISO $isoboot
