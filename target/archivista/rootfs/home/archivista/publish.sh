#!/bin/bash

# In-system livecd regenerator/repacker that will clone the installed
# system back to an ISO or USB device suiteable for booting and
# installation and even display a progress bar thru Xdialog while doing so.
#
# Copyright (C) 2006 Archivista GmbH
# Copyright (C) 2006 Rene Rebe

tmp=`mktemp`
ps --no-headers -C publish.sh > $tmp

# 2 due to foking a sub-process above :-(
if [ `cat $tmp | wc -l` -gt 1 ] ; then
	Xdialog --no-cancel --title 'Archive publishing' --msgbox \
	        "There is already a publishing process running! Only one instance
can compess the system, try again later." 0 0
	exit
fi

if [ "$UID" -ne 0 ]; then
        exec gnomesu -t "Archive publishing" \
        -m "Please enter the system password (root user)^\
in order to publish the archive." -c $0
fi

# PATH and co
. /etc/profile

# Xdialog and friends
export DISPLAY=:0

set -e

livedir=/home/data/publishing
dbdir=/home/data/archivista/mysql
ocrkey=/home/archivista/.wine/drive_c/Programs/Av5e/av5.con

cleanup ()
{
	rm -rf boot root
}

# database selection from the user
cd $dbdir
i=0
for x in * ; do
	[ -d "$x" ] || continue
	case "$x" in
		mysql|test) continue ;;
	esac
	dbs[$((i++))]="$i"
	dbs[$((i++))]="$x"
	if [ "$x" = archivista ]; then
		dbs[$((i++))]="on"
	else
		dbs[$((i++))]="off"
	fi
done

while [ -z "$d" ]; do
	d=`Xdialog --stdout --password --no-tags --separator ' ' \
	   --title 'Archive publishing' --checklist \
	   "Choose the databases to be published." 0 0 3 "${dbs[@]}"` || exit
	[ "$d" ] || Xdialog --no-cancel --title 'Archive publishing' --msgbox \
	                    "You need to select at least one database!" 0 0
done

# generate exclude list and find out if the archivista db is selected
n=$i; i=0
d=" $d " # terminating space
dbexclude=
dbselected=
archivistadb=1
while [ $i -lt $n ]; do
	# selected?
	if [ "${d/ $i /}" != "$d" ]; then
		echo $i selected
		dbselected="$dbselected ${dbs[$((i+1))]}"
	else
		echo $i not seleted
		if [ "${dbs[$((i+1))]}" = archivista ]; then
			archivistadb=0
			dbexclude="$dbexclude $dbdir/__archivista"
		else
			dbexclude="$dbexclude $dbdir/${dbs[$((i+1))]}"
		fi
		dbexclude="$dbexclude /home/data/archivista/images/${dbs[$((i+1))]}"
	fi
	: $(( i += 3 ))
done

echo database selected: $dbselected
echo database exclude: $dbexclude
echo archivista db: $archivistadb

# sanity check
Xdialog --title 'Archive publishing' --cancel-label Cancel \
        --yesno "The following databases will be
included in the archive:
${dbselected// /\n}" 0 0 || exit

mkdir -p $livedir/root ; cd $livedir
cleanup ; rm -f live.squash

# list of top-level dirs
dirs=
for dir in /* ; do
	[ -d $dir ] || continue
	case $dir in
		# do not include the virtual fs or mounted volumes
		/dev|/proc|/sys|/tmp|/mnt|/media)
			mkdir -p root$dir
			continue
			;;
		# just skip
		/boot-cd)
			continue
			;;
		# we need to slightly tweak /etc
		/etc)
			rsync -art $dir/ root$dir/
			sed -i '/^[^ ]*dev[^ ]* /d' root/etc/fstab
			rm root/etc/mtab* root/etc/conf/network || true
			rm root/etc/net-backup.conf root/etc/rsync-backup.conf || true
			rm root/etc/mail.conf || true
			rm root/etc/ssh/*key* || true
			sed -i '/home\/archivista\//d' root/etc/crontab
			continue
			;;
	esac
	dirs="$dirs $dir"
done
echo "dirs: $dirs"

# list of data exclude dirs
dataexclude=/home/mysql.orig
for dir in /home/data/* ; do
	case $dir in
		# do include
		/home/data/archivista)
			continue
			;;
	esac
	dataexclude="$dataexclude $dir"
done
echo "dataexclude: $dataexclude"

# final tweaks, include vanilla files, and
# possibly injecting the default archivista db
chmod 1777 root/tmp

# approximate output size
# disc usage
sys_size=`df -B 1000000 -P / | tail -n 1 | tr -s ' ' | cut -d ' ' -f 3`
data_size=`du -B 1000000 -sc $dbdir | tail -n 1 | cut -f 1`

# substract excluded dbs
sub_size=0
if [ "$dbexclude" ]; then
	sub_size=`du -B 1000000 -sc ${dbexclude//__archivista/archivista} |
	          tail -n 1 | cut -f 1`
fi

# system has a lof of text, thus more than 2
out_size=$(( sys_size / 3 + ( data_size - sub_size ) / 2 ))

uncompr=`Xdialog --stdout --no-tags --title "Archive publishing" --radiolist \
         "Based on the system and data to be archived ($((sys_size + data_size - sub_size)) MB),
the estimated compressed media utilization is $out_size MB.

Please choose whether the archive should be compressed.
An uncompressed publications can be created faster but
is about 1GB + 20% of the database size larger and can
not be placed on an optical disc." 0 0 3 \
         compressed compressed on uncompressed uncompressed off` || exit
if [ "$uncompr" = compressed ]; then
	uncompr=
else
  uncompr="-noD -noI -noF -no-duplicates"
fi

unint_xdialog_w_file ()
{
	touch $2
	while true; do
		Xdialog --no-close --no-buttons --title 'Archive publishing' \
		 --infobox "$1\n(`ls -sh $2 |
  sed 's/ .*// ; s/M/ MB written/ ; s/^0$/creating file list/'`)" 0 0 20000
	done
}

rc apache stop
rc mysql stop

if [ $archivistadb = 0 ]; then
	# backup
	mv $dbdir/{archivista,__archivista}
	# new minimal
	mkdir -p $dbdir/archivista
	cp -afv /home/mysql.orig/* $dbdir/archivista/
	# copy missing
	for x in $dbdir/__archivista/* ; do
		[ -f $dbdir/archivista/${x##*/} ] ||
			cp -afv $x $dbdir/archivista/
	done
	# TODO, remove after check
	chown -R mysql:mysql $dbdir/archivista/
fi

unint_xdialog_w_file "The database archive and the currently running system
are beeing archived. This process will take quite some time." live.squash &
set -x
mksquashfs $dirs ./root/* live.squash -noappend -info $uncompr -e \
           $dataexclude $dbexclude $ocrkey \
           /home/archivista/.xkb-layout \
           /root/.ssh /home/archivista/.ssh /home/archivista/.gnupg \
           /home/data/archivista/mysql/*-bin.* \
           /home/data/archivista/mysql/{ib_*,ibdata1}
set +x
kill %- 2>/dev/null || true # the Xdialog

isoname=`date "+av-%Y%m%d-%H%M.iso"`

# only include the live.squash and show the progress if the ISO should
# be compressed, uncompressed we only place the boot code in the ISO so
# it is available for iso2stick to make the stick bootable as usual
if [ "$uncompr" ]; then
	lq=
else
	lq=live.squash
	unint_xdialog_w_file "The final disc image is beeing created.
This process will take a few minutes." $isoname &
fi

# copy initrd, grub, ...
cp -ar /boot-cd boot

# mkisofs, heavily copied out of the T2 sources, since there we add all the
# magic glue automagically ,-)))
set -x
mkisofs -q -r -T -J -l -o $isoname -A "Archivista Box" \
        -publisher 'Archivista Box based on the T2 SDE' \
        -b boot/grub/stage2_eltorito -no-emul-boot \
        -boot-load-size 4 -boot-info-table \
        --graft-points $lq boot=boot
set +x
chown archivista:users $isoname

if [ -z "$uncompr" -a \
     `du -B 1 --apparent-size live.squash | cut --f 1` -gt \
     `du -B 1 --apparent-size $isoname    | cut --f 1` ]; then
	Xdialog --title 'Archive publishing' --msgbox \
"The resulting ISO image has a size less than the compressed
file-system. Most probably it hit the 4GB file size limit of
the ISO9660 standard." 0 0
	exit
fi

kill %- 2> /dev/null || true # the Xdialog

if [ $archivistadb = 0 ]; then
	# restore
	rm -rf $dbdir/archivista
	mv $dbdir/{__archivista,archivista}
fi

rc mysql start
rc apache start

cleanup

### ISO generation END ###

if [ -z "$uncompr" ]; then
	rm live.squash
	Xdialog --title 'Archive publishing' \
	        --yesno "Disc image generation completed.
The compressed ISO image is `ls -sh $isoname | sed 's/ .*// ; s/\([MGT]\)/ \1B /'` \
and named
$PWD/$isoname.
Do you want to copy the archive to an USB device?" 0 0 || exit
fi

### USB device install BEGIN ###

# prevent hotplug backup
usblog=`mktemp`
touch /tmp/hot.lock
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

Xdialog --ok-label Cancel --title "Archive publishing" \
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
			[ -e "$d" ] && dev=$d	# u/dev device node exits?
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

if ! Xdialog --title "Archive publishing" --yesno \
"Really copy the archive to the USB device ($usbdev)?
All data will be lost!" 0 0; then
	continue
fi

# convert it, multi threaded displaying
Xdialog --no-close --no-buttons --title "Copying archive to USB device" \
        --logbox $usblog 25 80 &

# additionally inject the non-ISO live.squash in the uncompressed case
if [ "$uncompr" ]; then
	lq=live.squash
	fs="-fs ext2"
else
	lq=
	fs=
fi

echo -e "Copying archive to USB device ($usbdev):\n" > $usblog
set -x
${0%/*}/iso2stick.sh $fs ./$isoname $usbdev $lq >> $usblog 2>&1 &
set +x

if ! wait %2 ; then  # wait for the iso2stick
	Xdialog --title "Archive publishing" --msgbox \
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

Xdialog --no-cancel --title "Archive publishing" \
        --msgbox "Archive copied to the USB device." 0 0

# do not ask when uncompressed, the ISO is boot code only in this case
if [ "$uncompr" ] || Xdialog --default-no --title "Archive publishing" \
           --yesno "Delete published archive now?" 0 0; then
	rm -v ./$isoname
fi

