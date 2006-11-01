#!/bin/bash

# iso2stick graphical frontend
#
# Copyright (C) 2006 Archivista GmbH
# Copyright (C) 2006 Rene Rebe

argv="$0"
for x do
  argv="$argv \"$x\""
done

if [ "$UID" -ne 0 ]; then
        exec gnomesu -t "Copy CD to USB storage" \
        -m "Please enter the system password (root user)^\
in order to copy a CD to USB storage device." -c "$argv"
fi

# PATH and co
. /etc/profile

# Xdialog and friends
export DISPLAY=:0

title=
isoname=
fs=

while [ "$1" ]; do
	case "$1" in
	-title) shift; title="$1" ;;
	-fs) shift; fs="-fs $1" ;;
	*) break
	esac
	shift
done

if [ "$1" ]; then
	isoname="$1"
	shift
else
	mkdir -p /mnt/source
	echo "Searching for Live CD"

	for dev in /dev/cdrom*; do
	  if mount $dev /mnt/source; then
		[ -e /mnt/source/live.squash ] && isoname=$dev
		umount /mnt/source
		[ "$isoname" ] && break
	  fi
	done

	if [ ! "$isoname" ]; then
		echo "Usage: $0 [ -title title ] [ iso ]"
		Xdialog --title "$title" --msgbox "No suitable CD found" 0 0
		exit 1
	fi
fi


### USB device install BEGIN ###

usblog=`mktemp`
touch /tmp/hot.lock # prevent hotplug backup
rc hal stop

# wait for a stick injection
usbdev=

get_device_list () {
	# from livecd init, best kept in sync ,-) -ReneR
	for x in /sys/block/*/device; do
		case "`ls -l $x`" in
			*/usb*|*/ieee1394) : ;;
			*) continue ;;
		esac
		x=${x%/device}; x=/dev/${x#/sys/block/}
		echo -n " $x "
	done
}

archived=0
while [ $archived -eq 0 ]; do

Xdialog --ok-label Cancel --title "$title" \
        --msgbox "Waiting for USB device. Please insert
the device you want to use." 0 0 &

initial_list="`get_device_list`"
dev=
while [ -z "$dev" ] && jobs %- ; do # while no device and not cancel
	sleep 1
	# get a new list
	new_list="`get_device_list`"

	# is there a new one?
	new_one=0
	for d in $new_list; do
		if [ "${initial_list/ $d /}" = "$initial_list" ]; then
			new_one=1
			[ -e "$d" ] && dev=$d # u/dev device node exits?
		fi
	done
	if [ $new_one -eq 0 ]; then
		# update the list, so pulling a device and inserting one works (both sda)
		initial_list="$new_list"
	fi
done
usbdev=$dev


kill %- 2> /dev/null || true # the Xdialog
if [ -z "$usbdev" ]; then
	rm /tmp/hot.lock
	rc hal start
	exit
fi

sleep 1 # work around to let the above job disappear ...

if ! Xdialog --title "$title" --yesno \
"Really copy the archive to the USB device ($usbdev)?
All data will be lost!" 0 0; then
	continue
fi

# convert it, multi threaded displaying
Xdialog --no-close --no-buttons --title "$title" \
        --logbox $usblog 25 80 &

echo -e "Copying archive to USB device ($usbdev):\n" > $usblog
set -x
eval ${0%/*}/iso2stick.sh $fs "$isoname" $usbdev "$@" >> $usblog 2>&1 &
set +x

if ! wait %2 ; then  # wait for the iso2stick
	Xdialog --title "$title" --msgbox \
	        "There was an error copying the archive." 0 0
	kill %- 2> /dev/null # the Xdialog
	continue
fi
kill %- 2> /dev/null # the Xdialog
archived=1

done

rm /tmp/hot.lock $usblog
rc hal start

### USB device install END ###

Xdialog --no-cancel --title "$title" \
        --msgbox "Archive copied to the USB device." 0 0
