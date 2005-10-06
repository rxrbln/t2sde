#!/bin/bash

# Simple custom installer using Xdialog for interaction. After selecting the
# target device it will clone the live-cd onto the hard-disk using
# rsync and even display a progress bar thru Xdialog while doing so.
#
# Copyright (C) 2005 Archivista GmbH
# Copyright (C) 2005 Rene Rebe

# PATH and co.
. /etc/profile

shadow=`mktemp`-shadow
parts=

mkdir -p /mnt/target

installall=0

# This is a bit tricky to filter and does not look too smooth
# due to the new linux pipe implementation ...
format_w_progress ()
{
	(
	  mkfs.ext3 $1 |
	  tr '\b' '\n' | tr ' ' '\n' |
	  sed -n 's/\([0-9]\+\/[0-9]\+\)/100*\1/p' |
	  bc | # binary calculator, evaluating the above generated math
	  sed 's/^\([1-9]\)$/0\1/' # append a 0 for single digits for Xdialog :-(
	) | Xdialog --progress "Formating $1 ..." 8 30
}


# collect partitions normally intended for archivista
for x in /dev/hd? /dev/sd? ; do
	[ -e $x ] || continue
	x=${x#/dev/}
	# skip CD-ROMs
	grep -q cdrom /proc/ide/$x/media 2>/dev/null && continue

	parts="$parts /dev/${x}-Reformat_whole_disk"

	for y in /dev/$x[12]; do
		if mount $y /mnt/target 2>/dev/null; then
			if [ -e /mnt/target/home/archivista ]; then
				parts="$parts ${y}-(Archivista)"
			else
				parts="$parts ${y}-(used)"
			fi
			umount /mnt/target
		else
			parts="$parts ${y}-(unknown)"
		fi
	done
done

if [ "$parts" ]; then
	part=`Xdialog --combobox "Please choose the disc partition
to install to:" 8 38 $parts 2>&1`
else
	echo "no partitions"
	exit
fi

# empty or reformat?
if [[  $part = *Reformat* ]]; then
	disk=${part%-*}
	if Xdialog --yesno "Formating the whole disk $disk.
All data will be lost!" 8 38; then

		installall=1

		sfdisk -uM $disk << EOT
,4096,L
,4096,L
,1024,S
,,L
EOT
		# install into the first partition on fresh installs ...
		part=${disk}1

		# u/dev needs some time to regenerate the device-nodes
		sleep 2
		i=0
		while [ $i -le 10 ]; do
			[ -e $part ] && break
			echo "waiting for u/dev nodes to come back"
			sleep 1
		done

		# initialize the swap
		mkswap ${disk}3

		format_w_progress ${disk}1
		format_w_progress ${disk}4
	else
		exit
	fi
fi

if [ $installall = 0 ]; then
	# TODO: copy the passwords if existing
	# grep 'root\|archivista' /mnt/target/etc/shadow > $shadow
	#                        cat $shadow

	# maybe TODO: take a look which archivista setup is activated in grub

	part=${part%-*}

	if ! Xdialog --yesno "Format partition $part.
All data will be lost!" 8 28; then
		echo cancelled
		exit
	fi

	format_w_progress $part
fi

mount $part /mnt/target

# sanity check to not install into the running system's RAM-disk
if ! grep -q /mnt/target /proc/mounts; then
	Xdialog --msgbox "Partiton could not be mounted. Aborting." 8 40
	exit
fi

if [ $installall -eq 1 ]; then
	mkdir -p		/mnt/target/home/data
	mount ${part%[0-9]}4	/mnt/target/home/data

	if ! grep -q /mnt/target/home/data /proc/mounts; then
		Xdialog --msgbox "Partiton could not be mounted. Aborting." 8 40
		umount /mnt/target
		exit
	fi

	# stop mysql for rsync
	rc mysql stop
fi

rsync  -arvP /mnt/live/ /mnt/target/ |
  sed -n 's/.* \([0-9]\+.[0-9]\)% .*/\1/p' |
  Xdialog --progress "Installing ..." 8 28

cat >> /mnt/target/etc/fstab <<-EOT
${part%[0-9]}3	swap		swap	defaults        0 0
${part%[0-9]}4	/home/data	auto	defaults	0 0
EOT

echo installing boot loader ...

mount --bind /dev /mnt/target/dev
mount --bind /proc /mnt/target/proc

chroot /mnt/target stone -text grub <<-EOT
1

2

3

EOT

sync

umount /mnt/target/dev
umount /mnt/target/proc
umount /mnt/target/home/data
umount /mnt/target

if [ $installall -eq 1 ]; then
	# restart mysql
	rc mysql start
fi

if ! grep -q /mnt/target /proc/mounts; then
	Xdialog --msgbox "Installation finished!
You can safely reboot now." 8 28
else
	Xdialog --msgbox "Target partition still mounted -
this indicates an error during installation." 8 38
fi
