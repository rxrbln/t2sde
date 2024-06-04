#!/bin/sh

source ${0%/*}/qemu.in

[ "$isoboot" ] || exit 43

# only thru kvm for performance reasons
[ "${qemuargs/--enable-kvm/}" = "$qemuargs" ] && exit 42

cd $SYSROOT

hda=/tmp/$$.hda
qemu-img create $hda -f qcow2 10G
expect -f ${0%.cmd}.exp $QEMUSYS $qemuargs -m $normmem ${extstorage}$ISO $isoboot ${intstorage}$hda
ret=$?
rm -f $hda
exit $?
