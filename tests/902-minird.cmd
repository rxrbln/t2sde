#!/bin/sh

source ${0%/*}/qemu.in

cd $SYSROOT
expect -f ${0%/*}/901-initrd.exp $QEMUSYS boot/$vmlinux boot/minird "$append" $qemuargs -m $lowmem 
