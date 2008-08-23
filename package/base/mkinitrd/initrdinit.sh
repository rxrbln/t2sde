#!/bin/sh

echo "T2 SDE early userspace (C) 2005 - 2008 Rene Rebe, ExactCODE"

PATH=/sbin:/bin:/usr/bin:/usr/sbin

echo "Mounting /dev, /proc and /sys ..."
mount -t tmpfs none /dev -o mode=755
mount -t proc  none /proc
mount -t usbfs none /proc/bus/usb 2> /dev/null
mount -t sysfs none /sys
ln -s /proc/self/fd /dev/fd

echo "Populating u/dev ..."
mknod /dev/null c 1 3
mknod /dev/zero c 1 5
udevd &
udevtrigger
udevsettle
[ -e /dev/console ] || mknod /dev/console c 5 1
[ -e /dev/tty ] || mknod /dev/tty c 5 0

echo "Loading additional subsystem and filesystem driver ..."
# well some hardcoded help for now ...
for x in sbp2 ide-generic ide-disk ide-cd sd_mod sr_mod sg raid1; do
	modprobe $x 2> /dev/null
done

# the modular filesystems ...
for x in /lib/modules/*/kernel/fs/{*/,}*.*o ; do
	x=${x##*/} ; x=${x%.*o}
	modprobe $x 2> /dev/null
done

echo "Assembling MD arrays"
[ -e /etc/mdadm.conf ] && mdadm --assemble --scan

# get the root device and init
root="root= `cat /proc/cmdline`" ; root=${root##*root=} ; root=${root%% *}
init="init= `cat /proc/cmdline`" ; init=${init##*init=} ; init=${init%% *}

# maybe resume from disk?
resume="`cat /proc/cmdline`"
if [[ "$resume" = *resume* ]] && [[ "$resume" != *noresume* ]]; then
	resume=${resume##*resume=} ; resume=${resume%% *}
	resume=`ls -l $resume |
sed 's/[^ ]* *[^ t]* *[^ ]* *[^ ]* *\([0-9]*\), *\([0-9]*\) .*/\1:\2/'`
	echo "Attempting to resume from disk $resume."
	echo "$resume" > /sys/power/resume
fi

# try best match / detected rootfs first, all the others thereafter
filesystems=`disktype $root 2>/dev/null |
             sed -e '/file system/!d' -e 's/file system.*//' -e 's/ //g' \
                 -e 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/' \
                 -e 's/fat32/vfat/'
             sed '1!G ; $p ; h ; d' /proc/filesystems | sed /^nodev/d`

mkdir /rootfs

if [ "$root" ]; then
  echo "Mounting rootfs ..."

  i=0
  while [ $i -le 9 ]; do
	for fs in $filesystems ; do
	  if mount -t $fs $root /rootfs -o ro 2> /dev/null; then
		echo "Successfully mounted rootfs as $fs."

		# TODO: later on search other places if we want 100% backward compat.
		[ "$init" ] || init=/sbin/init
		if [ -f /rootfs/$init ]; then
			kill %1
			mount -t none /dev -o move /rootfs/dev
			mount -t none /proc -o move /rootfs/proc
			mount -t none /sys -o move /rootfs/sys

			exec switch_root /rootfs $init $*
		else
			echo "Specified init ($init) does not exist!"
		fi
	  fi
	done
  [ $(( i++ )) -eq 0 ] && echo "Waiting for root device to become ready ..."
  sleep 1
  done
fi

echo "Ouhm - some boot problem, but I do not scream. Debug shell:"
exec /bin/sh
