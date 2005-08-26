#!/bin/bash

# Simple custom installer using Xdialog for interaction. After selecting the
# target device it will clone the live-cd onto the hard-disk using
# rsync and even display a progress bar thru Xdialog while doing so.
#
# Copyright (C) 2005 Archivista GmbH
# Copyright (C) 2005 Rene Rebe

PATH=/sbin:/usr/sbin:$PATH

shadow=`mktemp`-shadow
parts=

mkdir -p /mnt/target

installall=0

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
	x=${part%-*}
	if Xdialog --yesno "Formating the whole disk $x.
All data will be lost!" 8 38; then

		installall=1

		sfdisk -uM $x << EOT
,4096,L
,4096,L
,1024,S
,,L
EOT
		# u/dev needs some time to regenerate the device-nodes
		sleep 2

		# install into the first partition on fresh installs ...
		part=/dev/hda1

		Xdialog --infobox "Formating filesystems,
this may take some seconds." 8 38 20000

		# initialize the swap
		mkswap ${part%[0-9]}3
		# format the partitions
		mkfs.ext3 ${part%[0-9]}1
		mkfs.ext3 ${part%[0-9]}4
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

	mkfs.ext3 $part
fi

set -x
mount $part /mnt/target

# sanity check to not install into the running system's RAM-disk
if ! grep -q /mnt/target /proc/mounts; then
	Xdialog --infobox "Partiton could not be mounted. Exiting." 8 30
	exit
fi

if [ $installall -eq 1 ]; then
	mkdir -p		/mnt/target/home/data
	mount ${part%[0-9]}4	/mnt/target/home/data

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

umount /mnt/target/dev
umount /mnt/target/proc
umount /mnt/target/home/data
umount /mnt/target

if [ $installall -eq 1 ]; then
	# restart mysql
	rc mysql start
fi

Xdialog --infobox "Installation finished. You
can safely reboot now." 8 28 200

