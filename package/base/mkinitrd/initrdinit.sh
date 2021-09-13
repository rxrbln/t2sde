#!/bin/sh

PATH=/sbin:/bin:/usr/bin:/usr/sbin

echo "T2 SDE early userspace (c)2005-2021 Rene Rebe, ExactCODE GmbH; Germany."

echo "Mounting /dev, /proc and /sys"
mount -t devtmpfs -o mode=755 none /dev
mount -t proc none /proc
mount -t sysfs none /sys
mkdir -p /tmp /mnt
ln -s /proc/self/fd /dev/fd

echo "$(< /proc/sys/kernel/ostype) $(< /proc/sys/kernel/osrelease)," \
"populating u/dev"
udevd &
udevadm trigger
udevadm settle

# get the root device, init, early swap
cmdline="$(< /proc/cmdline)" 
root="root= $cmdline" ; root=${root##*root=} ; root=${root%% *}
init="init= $cmdline" ; init=${init##*init=} ; init=${init%% *}
swap="swap= $cmdline" ; swap=${swap##*swap=} ; swap=${swap%% *}

[ "${root#UUID=}" != "$root" ] && root="/dev/disk/by-uuid/${root#UUID=}"
[ "${swap#UUID=}" != "$swap" ] && swap="/dev/disk/by-uuid/${swap#UUID=}"

# maybe resume from disk?
resume="$(< /proc/cmdline)"
if [[ "$resume" = *resume* ]] && [[ "$resume" != *noresume* ]]; then
	resume=${resume##*resume=} ; resume=${resume%% *}
	resume=`ls -l $resume |
sed 's/[^ ]* *[^ t]* *[^ ]* *[^ ]* *\([0-9]*\), *\([0-9]*\) .*/\1:\2/'`
	echo "Attempting to resume from disk $resume."
	echo "$resume" > /sys/power/resume
fi

if [ "$swap" ]; then
	echo "Activating swap"
	swapon $swap
fi

if [ "$root" ]; then
  mountopt="ro"

  # diskless network root?
  addr="${root%:*}"
  if [ "$addr" != "$root" ]; then
    mountopt="$mountopt,nolock,port=2049,mountport=32790,vers=4,addr=$addr"
    filesystems="nfs"
    ipconfig eth0
  else
    unset addr
    if [ ! -e "$root" ]; then
	echo "Activating RAID & LVM"
	[ -e /sbin/mdadm ] && mdadm --assemble --scan
	[ -e /sbin/lvchange ] && lvchange -a ay ${root#/dev/}
    fi
    if [ ! -e "$root" ]; then
	modprobe pata_legacy
    fi
  fi

  echo "Mounting root $mountopt"

  i=0
  while [ $i -le 9 ]; do
    if [ -e $root -o "$addr" ]; then
	if [ -z "$addr" ]; then
	  type -p cryptsetup && cryptsetup isLuks $root --disable-locks &&
	          cryptsetup luksOpen $root root --disable-locks && root=/dev/mapper/root

	  # try best match / detected root first, all the others thereafter
	  filesystems=`disktype $root 2>/dev/null |
	    sed -e '/file system/!d' -e 's/file system.*//' -e 's/ //g' \
		-e 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/' \
		-e 's/fat32/vfat/'
	    sed '/^nodev/d' /proc/filesystems | sed '1!G; $p; h; d'`
	fi
	for fs in $filesystems; do
	  if mount -t $fs -o $mountopt $root /mnt 2> /dev/null; then
		echo "Successfully mounted root as $fs."
		# TODO: later on search other places if we want 100% backward compat?
		init=${init:-/sbin/init}
		if [ -f /mnt$init ]; then
			kill %1
			mount -t none -o move {,/mnt}/dev
			mount -t none -o move {,/mnt}/proc
			mount -t none -o move {,/mnt}/sys
			exec switch_root /mnt $init $*
		else
			echo "Specified init ($init) does not exist!"
		fi
		break 2
	  fi
	done
    fi
  [ $(( i++ )) -eq 0 ] && echo "Waiting for root device to become ready."
  sleep 1
  done
fi

# PANICMARK

echo "No root or init, but we do not scream, debug shell:"
kill %1
exec /bin/sh
