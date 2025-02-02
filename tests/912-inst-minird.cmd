#!/bin/sh

source ${0%/*}/qemu.in

cd $SYSROOT
expect -f ${0%.cmd}.exp $QEMUSYS boot/$vmlinux TOOLCHAIN/isofs/boot/minird-* \
	"$append" $qemuargs -m $((lowmem + 16)) ${extstorage}$ISO # mem=512m
