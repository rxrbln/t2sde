#!/bin/sh

PATH=/sbin:/bin:/usr/bin:/usr/sbin

echo "T2 SDE early userspace (c)2005-2023 Rene Rebe, ExactCODE GmbH; Germany."

function mapper2lvm {
	# support both, direct vg/lv or mapper/...
	x=${1#mapper/} 
	if [ "$x" != "$1" -a "${x#*-}" != "$x" ]; then
		# TODO: --
		x="${x%-*}/${x#*-}"
	fi
	echo $x
}

function boot {
	mount -t none -o move {,/mnt}/dev
	mount -t none -o move {,/mnt}/proc
	mount -t none -o move {,/mnt}/sys
	exec switch_root /mnt "$@"
}

mount -t proc none /proc
[ -e /proc/sys/kernel/ostype ] &&
	echo "$(< /proc/sys/kernel/ostype) $(< /proc/sys/kernel/osrelease)," \
"mounting /dev, /proc, /sys and starting u/devd."
mount -t devtmpfs -o mode=755 none /dev
mount -t sysfs none /sys
mkdir -p /tmp /mnt
ln -s /proc/self/fd /dev/fd

udevd &
udevadm trigger
udevadm settle

# if no block devices, load some legacy drivers
if [ -z "$(ls -A /sys/block | sed '/^loop/d; /^fd/d')" ]; then
	modprobe pata_legacy all=2 2>/dev/null
fi

# get the root device, init, early swap
[ -e /proc/cmdline ] && cmdline="$(< /proc/cmdline)"
root="root= $cmdline" root=${root##*root=} root=${root%% *}
init="init= $cmdline" init=${init##*init=} init=${init%% *}
swap="swap= $cmdline" swap=${swap##*swap=} swap=${swap%% *}
resume="resume= $cmdline" resume=${resume##*resume=} resume=${resume%% *}
mountopt="ro"

# wait for and mount root device, if specified
i=0
while [[ -n "$root" && ($((i++)) -le 15 || "$cmdline" = *rootwait*) ]]; do
  # only print once, for the 2nd iteration
  [ $i = 2 ] && echo "Waiting for $root ..."
  [ $i -gt 1 ] && sleep 1

  # open luks for lvm2 and resume from disk early
  if [ "${root%,*}" != "$root" ]; then
	toor="${root%,*}"
	[ "${toor#UUID=}" != "$toor" ] && toor="/dev/disk/by-uuid/${root#UUID=}"
	[ -e "$toor" ] || continue

	cryptsetup --disable-locks luksOpen $toor root && root="${root#*,}"
  fi

  [ "${root#UUID=}" != "$root" ] && root="/dev/disk/by-uuid/${root#UUID=}"
  [ "${swap#UUID=}" != "$swap" ] && swap="/dev/disk/by-uuid/${swap#UUID=}"

  # maybe resume from disk?
  if [[ "$resume" != "" && "$cmdline" != *noresume* ]]; then
	if [ ! -e $resume -a ${resume#/dev/*/*} != $resume -a -e /sbin/lvm ]; then
		lvs $(mapper2lvm ${resume#/dev/}) >/dev/null 2>&1 || continue
		echo "Activating LVM $resume"
		lvchange -a ay $(mapper2lvm ${resume#/dev/})
	fi
	
	# only try to resume if the device does not have a swap signature
	if [ -z "$(disktype $resume | sed  -n "/swap,/p")" ]; then
		resume=`ls -lL $resume |
		  sed 's/[^ ]* *[^ t]* *[^ ]* *[^ ]* *\([0-9]*\), *\([0-9]*\) .*/\1:\2/'`
	
		echo "Resuming from $resume"
		echo "$resume" > /sys/power/resume
		echo "Warning: Resume failed. Please check the kernel log for details."
		resume=
	fi
  fi

  if [ "$swap" ]; then
	echo "Activating swap"
	swapon $swap && swap=
  fi

  # diskless network root?
  addr="${root%:*}"
  if [ "$addr" != "$root" ]; then
    root="${root#$addr}" filesystems="nfs"
    mountopt="vers=4,addr=$addr,$mountopt"
    ipconfig eth0
  else
    unset addr
    if [ ! -e "$root" ]; then
	[ ${dev#/dev/md[0-9]} != $root -a -e /sbin/mdadm ] &&
		echo "Scanning for mdadm RAID" &&
		mdadm --assemble --scan
	if [ ${root#/dev/*/*} != $root -a -e /sbin/lvm ]; then
		lvs $(mapper2lvm ${root#/dev/}) >/dev/null 2>&1 || continue
		echo "Activating LVM $root"
		lvchange -a ay $(mapper2lvm ${root#/dev/})
	fi
    fi
  fi

  if [ -e $root -o "$addr" ]; then
	echo "Mounting $root on / $mountopt"
	if [ -z "$filesystems" ]; then
	  if type -p cryptsetup >/dev/null && cryptsetup --disable-locks isLuks $root; then
	          cryptsetup --disable-locks luksOpen $root root &&
			root=/dev/mapper/root || break
	  fi

	  # try best match / detected root first, all the others thereafter
	  filesystems=`disktype $root 2>/dev/null |
	    sed -e '/file system/!d' -e 's/file system.*//' -e 's/ //g' \
		-e 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/' \
		-e 's/fat32/vfat/'
	    sed '/^nodev/d' /proc/filesystems | sed '1!G; $p; h; d'`
	fi

	for fs in $filesystems; do
	  if mount -t $fs -o $mountopt $root /mnt 2> /dev/null; then
		# TODO: search other places if we want 100% backward compat?
		init=${init:-/sbin/init}
		if [ -f /mnt$init ]; then
			kill %1
			boot $init "$@"
		else
			echo "Error: Init ($init) does not exist!"
		fi
		break 2
	  fi
	done

	break
    fi
done

# PANICMARK

echo "No root or init, but we do not scream, debug shell:"
#kill %1 # we leave udevd running for device hot-plug
exec /bin/sh
