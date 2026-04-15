#!/bin/sh

PATH=/sbin:/bin:/usr/bin:/usr/sbin

echo "T2 SDE early userspace (c)2005-2026 Rene Rebe, ExactCODE GmbH; Germany."

getopt() {
	_="$2 $1" _=${_##*$2} _=${_%% *}
	echo "$_"
	unset _
}

getdev() {
	case "$1" in
	PARTUUID=*) echo "/dev/disk/by-partuuid/${1#PARTUUID=}" ;;
	UUID=*) echo "/dev/disk/by-uuid/${1#UUID=}" ;;
	LABEL=*) echo "/dev/disk/by-label/${1#LABEL=}" ;;
	*) echo "$1" ;;
	esac
}

mapper2lvm() {
	# support both, direct vg/lv or mapper/...
	x=${1#mapper/}
	if [ "$x" != "$1" -a "${x#*-}" != "$x" ]; then
		x="${x//--/	}" x="${x/-//}" x="${x//	/-}"
	fi
	echo $x
}

boot() {
	mount -t none -o move {,/mnt}/dev
	mount -t none -o move {,/mnt}/proc
	mount -t none -o move {,/mnt}/sys
	exec switch_root /mnt "$@"
}

overlayfs() {
	if [ ! -e $mnt/$overlay ]; then
		echo "No $mnt/$overlay to overlay."
		return 1
	fi

	mkdir -p /mnt/{mnt,overlay,work}
	modprobe loop 2>/dev/null

	if ! losetup /dev/loop0 $mnt/$overlay; then
		echo "Failed to setup /dev/loop0"
		return 1
	fi

	mount -t squashfs -o ro /dev/loop0 /mnt/mnt &&
		mount -t overlay -o lowerdir=/mnt/mnt,upperdir=/mnt/overlay,workdir=/mnt/work \
			none /mnt &&
		return 0

	echo "Failed to loop mount $overlay"
	losetup -d /dev/loop0
}

mount -t proc proc /proc
[ -e /proc/sys/kernel/ostype ] &&
	echo "$(< /proc/sys/kernel/ostype) $(< /proc/sys/kernel/osrelease)," \
"mounting /dev, /proc, /sys and starting u/devd."
mount -t devtmpfs -o mode=755 devtmpfs /dev
mount -t sysfs sysfs /sys
mkdir -p /tmp /run /var/run
ln -sf /proc/self/fd /dev/fd

udevd &

[ -e /proc/cmdline ] && cmdline="$(< /proc/cmdline)"

modules=$(getopt "$cmdline" rd.modprobe=)
for m in ${modules//,/ }; do modprobe $m; done
udevadm trigger --action=add
udevadm settle

# if no fb, try legacy drivers
if [ -z "$(cat /proc/fb 2>/dev/null)" ]; then
	modprobe offb 2>/dev/null
fi

# if no block devices, load some legacy drivers
if [ -z "$(ls -A /sys/block | sed '/^loop/d; /^fd/d')" ]; then
	modprobe pata_legacy all=2 2>/dev/null
fi

# get the root device, init, early swap
root=$(getdev $(getopt "$cmdline" root=))
init=$(getdev $(getopt "$cmdline" init=))
swap=$(getdev $(getopt "$cmdline" swap=))
[[ "$cmdline" != *noresume* ]] &&
	resume=$(getdev $(getopt "$cmdline" resume=))
mountopt=$(getopt "$cmdline" mountopt=)
mountopt="ro${mountopt:+,$mountopt}"
[ "$overlay" ] && mnt=/mnt/media || mnt=/mnt
mkdir -p $mnt

# parse cmdline
for v in $cmdline; do
    case "$v" in
    ro)	mountopt="ro${mountopt#r[ow]}" ;;
    rw)	mountopt="rw${mountopt#r[ow]}" ;;
    esac
done

# diskless network root?
addr="${root%:*}"
if [ "$addr" != "$root" -o "${addr%%,*}" = "/dev/nfs" ]; then
    filesystems="nfs"
    mountopt="vers=4,$mountopt"
    addr=${addr%%,*}

    # parse additional, comma separated options
    _mountopt="$root" root=${root%%,*}
    _mountopt="${_mountopt#$root}" _mountopt="${_mountopt#,}"

    _IFS="$IFS" IFS=','
    for v in $_mountopt; do
	case "$v" in
	if=*)	netif="${v#if=}" ;;
	*)	mountopt="$mountopt,$v" ;;
	esac
    done
    IFS="$_IFS"
    unset _IFS _mountopt

    [ "$netif" ] || netif=eth0

    # shadow $root, to allow loop to wait for nic, first
    _root=$root
    root=/sys/class/net/$netif
else
    unset addr
fi

# wait for and mount root device, if specified
i=0 n=
while [[ -n "$root" && ($((i++)) -le 15 || "$cmdline" = *rootwait*) ]]; do
  # only print once, for the 2nd iteration
  [ $i = 2 ] && echo -n "Waiting for $root "
  [ $i -gt 1 ] && echo -n "." && sleep 1 && n="
"

  # open luks for lvm2 and resume from disk early
  if [[ "${root}" = *,* ]]; then
	toor=${root%,*}
	[ -e "$toor" ] || continue

	echo -n "${n}"; n=
	cryptsetup --disable-locks luksOpen $toor root && root=$(getdev ${root#*,})
  fi

  
  # maybe resume from disk?
  if [ "$resume" ]; then
	if [[ ! -e $resume && "${resume}" = /dev/*/* && -e /sbin/lvm ]]; then
		if lvs $(mapper2lvm ${resume#/dev/}) >/dev/null 2>&1; then
			echo "${n}Activating LVM $resume"; n=
			lvchange -a ay $(mapper2lvm ${resume#/dev/})
		fi
	fi
	
	# only try to resume if the device does not have a swap signature
	if [ -e $resume ]; then
		if [ -z "$(disktype $resume | sed -n "/swap,/p")" ]; then
			resume=`ls -lL $resume |
		  	sed 's/[^ ]* *[^ t]* *[^ ]* *[^ ]* *\([0-9]*\), *\([0-9]*\) .*/\1:\2/'`

			echo "${n}Resuming from $resume"; n=
			echo "$resume" > /sys/power/resume
			echo "Warning: Resume failed. Please check the kernel log for details."
		fi
		resume=
	elif [ $i -ge 10 ]; then
		echo "Warning: Timed out waiting for $resume to resume."
		resume=
	else
		continue
	fi
  fi

  if [ "$swap" ]; then
	echo "${n}Activating swap"; n=
	swapon $swap && swap=
  fi

  if [ ! -e "$root" ]; then
	if [[ "${root}" = /dev/md[0-9]* && -e /sbin/mdadm ]]; then
		echo "${n}Scanning for mdadm RAID"; n=
		mdadm --assemble --scan
	fi
	# TODO: scripter not match /dev/disk/by-uuid/e561ecfc-1358-49e4-84b6-93a357900df3
	if [[ "${root}" = /dev/*/* && -e /sbin/lvm ]]; then
		lvs $(mapper2lvm ${root#/dev/}) >/dev/null 2>&1 || continue
		echo "${n}Activating LVM $root"; n=
		lvchange -a ay $(mapper2lvm ${root#/dev/})
	fi
  fi

  if [ -e "$root" ]; then
        if [ "$addr" ]; then
	    echo -n "${n}"; n=
	    ipconfig $netif

	    # get nfs details via bootp/dhcp server?
	    if [ "$addr" = "/dev/nfs" ]; then
		. /tmp/net-$netif.conf
		if [ "$ROOTPATH" ]; then
		    _root="$ROOTPATH"
		    addr="${_root%:*}"
		fi
	    fi

	    mountopt="addr=$addr,$mountopt"
	    root="$_root"; unset _root
	fi

	echo "${n}Mounting $root on / $mountopt"; n=
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
	  if mount -t $fs -o $mountopt $root $mnt 2>/dev/null; then
		[ "$overlay" ] && overlayfs

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

echo "${n}No root or init, but we do not scream, debug shell:"
#kill %1 # we leave udevd running for device hot-plug
exec /bin/sh
