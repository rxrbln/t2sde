#!/bin/sh

echo "T2 SDE early userspace (C) 2005 - 2019 Rene Rebe, ExactCODE"

PATH=/sbin:/bin:/usr/bin:/usr/sbin

echo "Mounting /dev, /proc and /sys ..."
mount -t devtmpfs -o mode=755 none /dev
mount -t proc none /proc
mount -t sysfs none /sys
ln -s /proc/self/fd /dev/fd

echo "Populating u/dev ..."
[ -e /dev/null ] || mknod /dev/null c 1 3
[ -e /dev/zero ] || mknod /dev/zero c 1 5
udevd &
udevadm trigger
udevadm settle
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

# get the root device and init
root="root= $(< /proc/cmdline)" ; root=${root##*root=} ; root=${root%% *}
init="init= $(< /proc/cmdline)" ; init=${init##*init=} ; init=${init%% *}

# maybe resume from disk?
resume="$(< /proc/cmdline)"
if [[ "$resume" = *resume* ]] && [[ "$resume" != *noresume* ]]; then
	resume=${resume##*resume=} ; resume=${resume%% *}
	resume=`ls -l $resume |
sed 's/[^ ]* *[^ t]* *[^ ]* *[^ ]* *\([0-9]*\), *\([0-9]*\) .*/\1:\2/'`
	echo "Attempting to resume from disk $resume."
	echo "$resume" > /sys/power/resume
fi

if [ ! -e "$root" ]; then
	echo "Assembling MD/LVM arrays"
	[ -e /sbin/mdadm ] && mdadm --assemble --scan
	[ -e /sbin/lvchange ] && lvchange -a ay ${root#/dev/}
fi

mkdir /root
if [ "$root" ]; then
  echo "Mounting root ..."

  i=0
  while [ $i -le 9 ]; do
    if [ -e $root ]; then
	type -p cryptsetup && cryptsetup isLuks $root &&
		cryptsetup luksOpen $root root && root=/dev/mapper/root

	# try best match / detected root first, all the others thereafter
	filesystems=`disktype $root 2>/dev/null |
	    sed -e '/file system/!d' -e 's/file system.*//' -e 's/ //g' \
		-e 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/' \
		-e 's/fat32/vfat/'
	    sed '/^nodev/d' /proc/filesystems | sed '1!G; $p; h; d'`
	for fs in $filesystems; do
	  if mount -t $fs -o ro $root /root 2> /dev/null; then
		echo "Successfully mounted root as $fs."
		# TODO: later on search other places if we want 100% backward compat.
		init=${init:-/sbin/init} 
		if [ -f /root/$init ]; then
			kill %1
			mount -t none -o move {,/root}/dev
			mount -t none -o move {,/root}/proc
			mount -t none -o move {,/root}/sys
			exec switch_root /root $init $*
		else
			echo "Specified init ($init) does not exist!"
		fi
		break 2
	  fi
	done
    fi
  [ $(( i++ )) -eq 0 ] && echo "Waiting for root device to become ready ..."
  sleep 1
  done
fi

echo "Ouhm - some boot problem, but I do not scream. Debug shell:"
kill %1
exec /bin/sh
