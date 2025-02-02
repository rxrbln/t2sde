#!/bin/sh

source ${0%/*}/qemu.in

cd $SYSROOT
[ -e usr/sbin/kexec ] || exit 43

expect -f ${0%.cmd}.exp $QEMUSYS boot/$vmlinux-* TOOLCHAIN/isofs/boot/initrd-* \
	"$append" $qemuargs -m $normmem ${extstorage}$ISO
