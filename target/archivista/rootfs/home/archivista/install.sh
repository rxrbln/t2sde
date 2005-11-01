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

mkdir -p /mnt/{target,update}

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
	) | Xdialog --progress "Formating $1 ..." 0 0
}

# collect partitions normally intended for archivista
i=0; j=0
updates[$((j++))]="no"
for x in /dev/hd? /dev/sd? ; do
	[ -e $x ] || continue
	x=${x#/dev/}
	# skip CD-ROMs - TODO extend this to SCSI
	grep -q cdrom /proc/ide/$x/media 2>/dev/null && continue

	# is it set up by our installer?
	reason=
	if [ `disktype /dev/$x | grep Partition | wc -l` != 4 ] ; then
		reason="Not exactly four partitions."
	elif [ `sfdisk -s /dev/${x}1` != `sfdisk -s /dev/${x}2` ]; then
		reason="First two partitions differ in size."
	elif [ `sfdisk -s /dev/${x}1` -le 4000000 ]; then
		reason="System partitions less than 4GB."
	elif [[ `disktype /dev/${x}3` != *swap* ]]; then
		reason="Third partition is not SWAP space."
	elif [[ `disktype /dev/${x}1` != *Ext[34]* ]] &&
	     [[ `disktype /dev/${x}2` != *Ext[34]* ]]; then
		reason="No system partition is initialized."
	elif [[ `disktype /dev/${x}4` != *Ext[34]* ]]; then
		reason="Data partition is not initialized."
	fi

	parts[$((i++))]="/dev/$x - Reformat whole disk"
	
	if [ "$reason" ]; then
		Xdialog --msgbox "/dev/$x does not appear to be formated for Archivista:
$reason" 0 0
	else
	    for y in /dev/$x[12]; do
		if mount $y /mnt/target 2>/dev/null; then
			ver=`sed 's/.*) - //' /mnt/target/etc/VERSION`
			if [ -e /mnt/target/home/archivista -a "$ver" ]; then
				parts[$((i++))]="${y} - Archivista ($ver)"
				updates[$((j++))]="${y} - Archivista ($ver)"
			else
				parts[$((i++))]="${y} - Formated but not Archivista"
			fi
			umount /mnt/target
		else
			parts[$((i++))]="${y} - Not formated"
		fi
	    done
	fi
done

echo "Partitions: ${parts[@]}"
echo "Updates possible: ${updates[@]}"

# partitions?
if [ ${#parts[@]} -gt 0 ]; then
	part=`Xdialog --stdout --combobox "Please choose the disc partition
to install to:" 0 0 "${parts[@]}"` || exit
else
	Xdialog --msgbox "No hard disk / partitions recognized." 0 0
	exit
fi

if [ ${#updates[@]} -gt 1 ]; then
  update=`Xdialog --stdout --combobox "Take over configuration from a
previous Archivista installation?" 0 0 "${updates[@]}"` || exit
fi

echo "Parition: $part"
echo "Update: $update"

if [ "$update" != "no" ]; then
	updatedev=${update%% *}
	rm -rf /tmp/update
	mkdir /tmp/update

	# not /mnt/target as safeguard if something fails
	if mount $updatedev /mnt/update; then
		${0%/*}/update-store.sh /mnt/update /tmp/update
		umount /mnt/update
		# TODO: window with list of extracted configs
	else
		Xdialog --msgbox "Partition $update, selected to take
over the configuration, could not be mounted." 0 0
        	exit
	fi
fi

# empty or reformat?
if [[ "$part" = *Reformat* ]]; then
	disk=${part%% *}
	if Xdialog --yesno "Formating the whole disk $disk.
All data will be lost!" 0 0; then

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
	part=${part%% *}

	if ! Xdialog --yesno "Installing to partition $part.
All data will be lost!" 0 0; then
		echo cancelled
		exit
	fi
fi

mount $part /mnt/target

# sanity check to not install into the running system's RAM-disk
if ! grep -q /mnt/target /proc/mounts; then
	Xdialog --msgbox "Partiton could not be mounted. Aborting." 0 0
	exit
fi

if [ $installall -eq 1 ]; then
	mkdir -p		/mnt/target/home/data
	mount ${part%[0-9]}4	/mnt/target/home/data

	if ! grep -q /mnt/target/home/data /proc/mounts; then
		Xdialog --msgbox "Partiton could not be mounted. Aborting." 0 0
		umount /mnt/target
		exit
	fi

	# stop mysql for rsync
	rc mysql stop
fi

rsync  -arvP --delete /mnt/live/ /mnt/target/ |
  sed -n 's/.* \([0-9]\+.[0-9]\)% .*/\1/p' |
  Xdialog --progress "Installing ..." 0 0

cat >> /mnt/target/etc/fstab <<-EOT
${part%[0-9]}3	swap		swap	defaults        0 0
${part%[0-9]}4	/home/data	auto	defaults	0 0
EOT

if [ "$update" ]; then
	echo "restore config"
	${0%/*}/update-restore.sh /tmp/update /mnt/target
	Xdialog --msgbox "Configuration restored." 0 0
fi

echo "installing boot loader ..."

# TODO: if there is another useful Archivista system add it to grub

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
You can safely reboot now." 0 0
else
	Xdialog --msgbox "Target partition still mounted -
this indicates an error during installation." 0 0
fi

