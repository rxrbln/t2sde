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
	( echo scale=3
	  mkfs.ext3 $1 |
	  tr '\b' '\n' | tr ' ' '\n' |
	  sed -n '/[0-9]\+\/[0-9]\+/p'
	) | bc | Xdialog --progress "Formating $1 ..." 8 30
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

# turn off write cache (just to be sure)
hdparm -W 0 /dev/hda

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
		i=0
		while [ $i -le 10 ]; do
			[ -e /dev/hda1 ] && break
			echo "waiting for u/dev node to come back"
			sleep 1
		done

		# install into the first partition on fresh installs ...
		part=/dev/hda1

		# initialize the swap
		mkswap ${part%[0-9]}3

		format_w_progress ${part%[0-9]}1
		format_w_progress ${part%[0-9]}4
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
	Xdialog --msgbox "Sys partiton could not be mounted. Aborting." 8 40
	exit
fi

# stop mysql for rsync
rc mysql stop

# 1st install the system

rsync  -arvP /mnt/live/ /mnt/target/ |
  sed -n 's/.* \([0-9]\+.[0-9]\)% .*/\1/p' |
  Xdialog --progress "Installing system ..." 8 28

# for now remove home/data/* afterwards
rm -rf /mnt/target/home/data/*

umount /mnt/target

if grep -q /mnt/target /proc/mounts; then
        Xdialog --msgbox "Sys partition still mounted -
this indicates an error during installation." 8 38
	exit
fi

# 2nd install data

if [ $installall -eq 1 ]; then
	mount ${part%[0-9]}4    /mnt/target

        if ! grep -q /mnt/target /proc/mounts; then
                Xdialog --msgbox "DB partiton could not be mounted. Aborting." 8 40
                exit
        fi

rsync  -arvP /mnt/live/home/data/ /mnt/target/ |
  sed -n 's/.* \([0-9]\+.[0-9]\)% .*/\1/p' |
  Xdialog --progress "Installing db ..." 8 28

	umount /mnt/target

if grep -q /mnt/target /proc/mounts; then
        Xdialog --msgbox "DB partition still mounted -
this indicates an error during installation." 8 38
fi


fi

# 3rd install boot loader

mount $part /mnt/target

# sanity check to not install into the running system's RAM-disk
if ! grep -q /mnt/target /proc/mounts; then
        Xdialog --msgbox "Sys partiton could not be mounted. Aborting." 8 40
        exit
fi


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
umount /mnt/target

# restart mysql
rc mysql start

sync

if grep -q /mnt/target /proc/mounts; then
	Xdialog --msgbox "Sys partition still mounted -
this indicates an error during installation." 8 38
fi

# now - check filesystems because we became paranoid

(
	echo "$part ..."
	e2fsck -fn $part
	echo "${part%[0-9]}4 ..."
	e2fsck -fn ${part%[0-9]}4 
) 2>&1 | Xdialog --title="Checking filesystems" --no-cancel --log - 50 60

Xdialog --msgbox "Installation finished." 8 28

