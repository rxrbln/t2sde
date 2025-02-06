#!/bin/sh

source ${0%/*}/qemu.in

[ "$isoboot" ] || exit 43

# only thru kvm for performance reasons
[ "${qemuargs/--enable-kvm/}" = "$qemuargs" ] && exit 42

cd $SYSROOT

hda=/tmp/$$.hda hdb=/tmp/$$.hdb
hda=/srv/hda hdb=/srv/hdb

qemu-img create $hda -f qcow2 120G
qemu-img create $hdb -f qcow2 120G
expect -f ${0%.cmd}.exp $QEMUSYS $qemuargs -smp 8 -m $((highmem * 8)) ${extstorage}$ISO $isoboot \
	${intstorage}$hda ${intstorage2}$hdb
ret=$?
#rm -f $hda $hdb
exit $?
