#!/bin/bash

# Custom installer using Xdialog for interaction. After selecting the
# target device it will clone the live-cd/stick onto the hard-disk using
# rsync and even display a progress bar thru Xdialog while doing so.
#
# It supports taking over configurations for a update and automatic
# installtion, if requested.
#
# Copyright (C) 2005, 2006 Archivista GmbH
# Copyright (C) 2005, 2006 Rene Rebe

# PATH and co.
. /etc/profile

if [ $UID -ne 0 ]; then
	echo "$0 must be run as root"
	exit
fi

shadow=`mktemp`-shadow
unset parts
declare -a parts
unset updates
declare -a updates
installall=0
full= # passed to the update scripts to not take over e.g. the passwords
auto=0

title="Installation"

while [ "$1" ]; do
	case "$1" in
		-auto) auto=1 ;;
		*) echo "Unrecognized argument \"$1\"." ;;
	esac
	shift
done

mkdir -p /mnt/{target,update}

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
	) | Xdialog --title "Formating ..." --progress "Formating $1 ..." 0 0
}

# collect partitions normally intended for archivista
i=0; j=0
updates[$((j++))]="no"
for x in /dev/hd? /dev/sd? ; do
	[ -e $x ] || continue
	x=${x#/dev/}
	# skip IDE CD-ROMs thare are hd* as well ...
	grep -q cdrom /proc/ide/$x/media 2>/dev/null && continue
	# skip mounted media, e.g. USB flash stick to install from
	grep -q "^/dev/$x" /proc/mounts && continue

	# is it set up by our installer?
	reason=
	if [ `disktype /dev/$x | grep Partition | wc -l` != 4 ] ; then
		reason="Not exactly four partitions."
	elif [ `sfdisk -s /dev/${x}1` -le 4000000 ]; then
		reason="First system partitions less than 4GB."
        elif [ `sfdisk -s /dev/${x}2` -le 4000000 ]; then
                reason="Second system partitions less than 4GB."
	elif [[ `disktype /dev/${x}3` != *swap* ]]; then
		reason="Third partition is not SWAP space."
	elif [[ `disktype /dev/${x}1` != *Ext[34]* ]] &&
	     [[ `disktype /dev/${x}2` != *Ext[34]* ]]; then
		reason="No system partition is initialized."
	elif [[ `disktype /dev/${x}4` != *Ext[34]* ]]; then
		reason="Data partition is not initialized."
	fi

	parts[$((i++))]="/dev/$x - Reformat whole disk"
	
	if [ $auto = 0 -a "$reason" ]; then
		Xdialog --title "$title" --msgbox \
		        "/dev/$x does not appear to be formated for Archivista:
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

echo "Partitions: '${parts[@]}' (${#parts[@]})"
echo "Updates possible: '${updates[@]}' (${#updates[@]})"

# partitions?
if [ ${#parts[@]} -gt 0 ]; then
	if [ $auto = 1 ]; then
		part="${parts[0]}"
	else
		part=`Xdialog --title "$title" --stdout \
		      --combobox "Please choose the disc partition
to install to:" 0 0 "${parts[@]}"` || exit
	fi
else
	Xdialog --title "$title" --msgbox "No hard disk / partitions recognized." 0 0
	exit
fi

if [[ "$part" = *Reformat* ]]; then
	installall=1
	full="-full"
fi


update="${updates[0]}"
if [ $auto = 0 -a ${#updates[@]} -gt 1 ]; then
	update=`Xdialog --title "$title" --stdout --combobox "Take over configuration from a
previous Archivista installation?" 0 0 "${updates[@]}"` || exit
fi

echo "Parition: '$part'"
echo "Update: '$update"

if [ "$update" != "no" ]; then
	updatedev=${update%% *}
	rm -rf /tmp/update
	mkdir /tmp/update

	# not /mnt/target as safeguard if something fails
	if mount $updatedev /mnt/update; then
		${0%/*}/update-store.sh /mnt/update /tmp/update
		umount /mnt/update

		# display extracted info
		${0%/*}/update-restore.sh -dry $full /tmp/update |
		Xdialog --title "Recognized configuration" --logbox - 0 0 || exit
	else
		Xdialog --title "$title" --msgbox "Partition $update, selected to take
over the configuration, could not be mounted." 0 0
        	exit
	fi
fi

# empty or reformat?
if [ $installall = 1 ]; then
	disk=${part%% *}
	if [ $auto = 1 ] || Xdialog --title "$title" \
	                            --yesno "Formating the whole disk $disk.
All data will be lost!" 0 0; then

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

		mount $part /mnt/target
	else
		exit
	fi
fi

if [ $installall = 0 ]; then
	part=${part%% *}

	# might not be yet formated ...
	if ! mount $part /mnt/target; then
		if ! Xdialog --title "$title" --yesno "Partition $part is not yet formated.
Format now?" 0 0; then
			echo cancelled
			exit
		fi

		format_w_progress $part
		mount $part /mnt/target
	else
		if ! Xdialog --title "$title" --yesno "Installing to partition $part.
All data will be lost!" 0 0; then
			echo cancelled
			umount /mnt/target
			exit
		fi
	fi
fi

# sanity check to not install into the running system's RAM-disk
if ! grep -q /mnt/target /proc/mounts; then
	Xdialog --title "$title" --msgbox "Partiton could not be mounted. Aborting." 0 0
	exit
fi

if [ $installall -eq 1 ]; then
	mkdir -p		/mnt/target/home/data
	mount ${part%[0-9]}4	/mnt/target/home/data

	if ! grep -q /mnt/target/home/data /proc/mounts; then
		Xdialog --title "$title" --msgbox "Partiton could not be mounted. Aborting." 0 0
		umount /mnt/target
		exit
	fi

	# stop mysql for rsync
	rc mysql stop
fi

rsync  -arvP --delete /mnt/live/ /mnt/target/ |
  sed -n 's/.* \([0-9]\+.[0-9]\)% .*/\1/p' |
  Xdialog --title "$title" --progress "Installing system and database
to the selected partitions." 0 0

# backup copies for publishing
rsync -arvP --exclude TRANS.TBL /media/cdrom/boot/ /mnt/target/boot-cd
(
	set -e
	# not .../data/... since maybe not mounted
	mkdir -p /mnt/target/home/mysql.orig
	cd /mnt/target/home/mysql.orig
	for db in archiv archivbilder archivseiten ; do
		cp -afv /mnt/live/home/data/archivista/mysql/archivista/$db.* .
	done
)

rm -f /mnt/target/etc/mtab*
cat >> /mnt/target/etc/fstab <<-EOT
${part}	/		auto	defaults	0 0
${part%[0-9]}3	swap		swap	defaults	0 0
${part%[0-9]}4	/home/data	auto	defaults	0 0
EOT

if [ "$update" != "no" ]; then
	echo "restore config"
	${0%/*}/update-restore.sh $full /tmp/update /mnt/target
	Xdialog --title "$title" --msgbox "Configuration restored." 0 0
fi

echo "installing boot loader ..."

mount --bind /dev /mnt/target/dev
mount --bind /proc /mnt/target/proc

# let the T2 stone module setup grub ,-)
touch /mnt/target/boot/grub/menu.lst
chroot /mnt/target stone -text grub <<-EOT
1

2

3

EOT

# other possible system partition
otherpart=`echo $part | tr 12 21`

if [ $installall = 0 ] && mount $otherpart /mnt/update; then
	echo "injecting other system's boot options into the grub menu"

	tmp=`mktemp`
	# save the other system's entries
	grep -A 1 -B 1 "root=$otherpart" /mnt/update/boot/grub/menu.lst |
		sed -e 's/^--//' -e 's/vista Box/vista Box 2nd Installation/' > $tmp
	# insert the other system's entry right before the MemTest entry
	sed -i "/MemTest/ { H; r $tmp
	       N }" /mnt/target/boot/grub/menu.lst

	umount /mnt/update

	Xdialog --title "$title" --msgbox "The alternative system partition
was added to the boot menu." 0 0
fi

sync # just paranoid

umount /mnt/target/dev
umount /mnt/target/proc
umount /mnt/target/home/data
umount /mnt/target

if [ $installall -eq 1 ]; then
	# restart mysql
	rc mysql start
fi

if ! grep -q /mnt/target /proc/mounts; then
	if [ $auto = 1 ]; then
		shutdown -h 0
	else
		Xdialog --title "$title" --msgbox "Installation finished!
You can safely reboot now." 0 0
	fi
else
	Xdialog --title "$title" --msgbox "Target partition still mounted -
this indicates an error during installation." 0 0
fi
